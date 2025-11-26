package edu.illinoistech.hawk.hwijaya;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.storage.StorageLevel;
import scala.Tuple2;

public class SparkVault {
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: SparkVault <hdfsOutputPath> <numRecords> <parallelism>");
            System.exit(1);
        }

        String outputPath = args[0];
        long totalRecords = Long.parseLong(args[1]);
        int parallelism = Integer.parseInt(args[2]);

        SparkConf conf =
            new SparkConf()
                .setAppName("SparkVault")
                .set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
                .set("spark.kryo.registrationRequired", "false")
                .set("spark.kryoserializer.buffer.max", "512m")
                .set("spark.hadoop.mapreduce.output.fileoutputformat.compress", "false");

        try (JavaSparkContext context = new JavaSparkContext(conf)) {
            long startTime = System.currentTimeMillis();
            context
                .parallelize(
                    IntStream.range(0, parallelism).boxed().collect(Collectors.toList()),
                    parallelism
                ).mapPartitions(iterator -> {
                    long recordsPerPartition = totalRecords / parallelism;
                    long remainder = totalRecords % parallelism;

                    int partitionIndex = 0;
                    if (iterator.hasNext()) {
                        partitionIndex = iterator.next();
                    }

                    long recordsToGenerate = recordsPerPartition;
                    if (partitionIndex < remainder) {
                        recordsToGenerate++;
                    }

                    List<byte[]> records = new ArrayList<>((int) recordsToGenerate);
                    for (long i = 0; i < recordsToGenerate; i++) {
                        records.add(Hashes.generate());
                    }

                    return records.iterator();
                }).persist(StorageLevel.MEMORY_AND_DISK_SER())
                .mapToPair(record -> {
                    BytesWritable bw = new BytesWritable();
                    bw.set(record, 0, Hashes.RECORD_BYTES);
                    return new Tuple2<>(bw, NullWritable.get());
                }).sortByKey(true, parallelism)
                .saveAsNewAPIHadoopFile(
                    outputPath,
                    BytesWritable.class,
                    NullWritable.class,
                    SequenceFileOutputFormat.class
                );

            System.out.printf(
                "Spark total time (including hashgen + sort + sort + HDFS write): %.2f seconds%n",
                (System.currentTimeMillis() - startTime) / 1000.0
            );
        }
    }
}
