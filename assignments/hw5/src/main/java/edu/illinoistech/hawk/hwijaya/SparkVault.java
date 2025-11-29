package edu.illinoistech.hawk.hwijaya;

import java.util.Collections;
import java.util.Iterator;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
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

        try (JavaSparkContext context =
                 new JavaSparkContext(
                     new SparkConf()
                         .setAppName("SparkVault")
                         .set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
                         .set("spark.kryo.registrationRequired", "false")
                         .set("spark.kryoserializer.buffer.max", "512m")
                         .set("spark.hadoop.mapreduce.output.fileoutputformat.compress", "false"
                     )
                 )
        ) {
            long startTime = System.currentTimeMillis();
            context.parallelize(
                    IntStream.range(0, parallelism).boxed().collect(Collectors.toList()),
                    parallelism
                )
                .mapPartitions(partitionIterator -> {
                    if (!partitionIterator.hasNext()) {
                        return Collections.emptyIterator();
                    }
                    int idx = partitionIterator.next();
                    long base = totalRecords / parallelism;
                    long remainder = totalRecords % parallelism;
                    long recordsToGenerate = base + (idx < remainder ? 1 : 0);
                    return new Iterator<byte[]>() {
                        long remaining = recordsToGenerate;

                        @Override
                        public boolean hasNext() {
                            return remaining > 0;
                        }

                        @Override
                        public byte[] next() {
                            remaining--;
                            return Hashes.generate();
                        }
                    };
                })
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
