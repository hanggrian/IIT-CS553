package edu.illinoistech.hawk.hwijaya;

import java.util.ArrayList;
import java.util.List;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import scala.Tuple2;

public class SparkVerify {
    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Usage: SparkVerify <sortedDataPath>");
            System.exit(1);
        }

        String inputPath = args[0];

        try (JavaSparkContext context =
                 new JavaSparkContext(
                     new SparkConf()
                         .setAppName("SparkVerify")
                         .set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
                         .set("spark.kryo.registrationRequired", "false")
                 )
        ) {
            long startTime = System.currentTimeMillis();

            JavaPairRDD<BytesWritable, NullWritable> data =
                context.sequenceFile(inputPath, BytesWritable.class, NullWritable.class);
            long totalRecords = data.count();
            List<VerificationResult> results =
                data.mapPartitions(partition -> {
                    List<VerificationResult> partitionResults = new ArrayList<>();
                    VerificationResult result = new VerificationResult();

                    byte[] previousRecord = null;
                    long recordCount = 0;
                    long errorCount = 0;

                    while (partition.hasNext()) {
                        Tuple2<BytesWritable, NullWritable> entry = partition.next();
                        byte[] currentRecord = new byte[entry._1().getLength()];
                        System.arraycopy(
                            entry._1().getBytes(),
                            0,
                            currentRecord,
                            0,
                            entry._1().getLength()
                        );

                        recordCount++;

                        if (previousRecord != null) {
                            int comparison = compareBytes(previousRecord, currentRecord);
                            if (comparison > 0) {
                                errorCount++;
                                if (errorCount <= 5) {
                                    System.err.printf(
                                        "Sort error in partition at record %,d%n",
                                        recordCount
                                    );
                                    System.err.printf(
                                        "  Previous: %s%n",
                                        bytesToHex(previousRecord)
                                    );
                                    System.err.printf(
                                        "  Current:  %s%n",
                                        bytesToHex(currentRecord)
                                    );
                                }
                            }
                        }

                        previousRecord = currentRecord;
                    }

                    result.recordCount = recordCount;
                    result.errorCount = errorCount;
                    partitionResults.add(result);

                    return partitionResults.iterator();
                }).collect();

            long totalErrors = results.stream().mapToLong(r -> r.errorCount).sum();
            long verifiedRecords = results.stream().mapToLong(r -> r.recordCount).sum();
            long elapsed = System.currentTimeMillis() - startTime;

            System.out.printf("Total records in dataset: %,d%n", totalRecords);
            System.out.printf("Records verified: %,d%n", verifiedRecords);
            System.out.printf("Sort errors found: %,d%n", totalErrors);
            System.out.printf("Verification time: %.2f seconds%n", elapsed / 1000.0);

            if (totalErrors <= 0) {
                return;
            }
            System.out.println("Data is NOT correctly sorted!");
            System.exit(1);
        }
    }

    private static int compareBytes(byte[] a, byte[] b) {
        int minLen = Math.min(a.length, b.length);
        for (int i = 0; i < minLen; i++) {
            int va = a[i] & 0xFF;
            int vb = b[i] & 0xFF;
            if (va != vb) {
                return va - vb;
            }
        }
        return a.length - b.length;
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < Math.min(bytes.length, 16); i++) {
            sb.append(String.format("%02x", bytes[i]));
        }
        if (bytes.length > 16) {
            sb.append("...");
        }
        return sb.toString();
    }

    static class VerificationResult implements java.io.Serializable {
        long recordCount = 0;
        long errorCount = 0;
    }
}
