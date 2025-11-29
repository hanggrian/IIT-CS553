package edu.illinoistech.hawk.hwijaya;

import java.io.Serializable;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.broadcast.Broadcast;

public class SparkSearch {
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: SparkSearch <sortedDataPath> <numSearches> <difficulty>");
            System.exit(1);
        }

        String inputPath = args[0];
        int numSearches = Integer.parseInt(args[1]);
        int difficulty = Integer.parseInt(args[2]);

        if (difficulty < 1 || difficulty > 8) {
            System.err.println("Difficulty must be between 1 and 8");
            System.exit(1);
        }

        System.out.printf("searches=%d difficulty=%d%n", numSearches, difficulty);

        try (JavaSparkContext context =
                 new JavaSparkContext(
                     new SparkConf()
                         .setAppName("SparkSearch")
                         .set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
                         .set("spark.kryo.registrationRequired", "false")
                 )
        ) {
            List<String> queries = generateSearchQueries(numSearches, difficulty);
            Broadcast<List<String>> broadcastQueries = context.broadcast(queries);
            Broadcast<Integer> broadcastDifficulty = context.broadcast(difficulty);

            long startTime = System.currentTimeMillis();
            JavaPairRDD<BytesWritable, NullWritable> data =
                context.sequenceFile(
                    inputPath,
                    BytesWritable.class,
                    NullWritable.class
                );
            List<Result> results =
                data
                    .flatMap(entry -> {
                        List<Result> matches = new ArrayList<>();
                        byte[] record = new byte[entry._1().getLength()];
                        System.arraycopy(
                            entry._1().getBytes(),
                            0,
                            record,
                            0,
                            entry._1().getLength()
                        );

                        String recordPrefix = bytesToHexPrefix(record, broadcastDifficulty.value());
                        for (String query : broadcastQueries.value()) {
                            if (!recordPrefix.equals(query)) {
                                continue;
                            }
                            Result result = new Result();
                            result.query = query;
                            result.fullHash = bytesToHex(record, 0, 10);
                            result.nonce = bytesToHex(record, 10, 6);
                            result.found = true;
                            matches.add(result);
                        }

                        return matches.iterator();
                    }).collect();
            long elapsed = System.currentTimeMillis() - startTime;

            Map<String, List<Result>> resultsByQuery = new HashMap<>();
            for (Result result : results) {
                resultsByQuery.computeIfAbsent(result.query, k -> new ArrayList<>()).add(result);
            }
            int resultIndex = 0;
            for (String query : queries) {
                List<Result> matches = resultsByQuery.get(query);
                if (matches != null && !matches.isEmpty()) {
                    for (Result match : matches) {
                        System.out.printf("[%d] %s MATCH %s %s%n",
                            resultIndex,
                            query,
                            match.fullHash,
                            match.nonce
                        );
                    }
                } else {
                    System.out.printf("[%d] %s NOTFOUND%n", resultIndex, query);
                }
                resultIndex++;
            }

            long foundQueries = resultsByQuery.size();
            long notFoundQueries = numSearches - foundQueries;
            long totalMatches = results.size();
            long estimatedComparisons = data.count() * queries.size();

            System.out.printf("Searches requested: %d%n", numSearches);
            System.out.printf("Searches performed: %d%n", numSearches);
            System.out.printf("Difficulty: %d%n", difficulty);
            System.out.printf("Found queries: %d%n", foundQueries);
            System.out.printf("Not found queries: %d%n", notFoundQueries);
            System.out.printf("Total matches: %d%n", totalMatches);
            System.out.printf("Total time: %.6f s%n", elapsed / 1000.0);
            System.out.printf(
                "Average time per search: %.3f ms%n",
                (elapsed / (double) numSearches)
            );
            System.out.printf(
                "Throughput: %.3f searches/sec%n",
                (numSearches * 1000.0) / elapsed
            );
            System.out.printf(
                "Estimated comparisons: %d%n",
                estimatedComparisons
            );
            System.out.printf(
                "Avg matches per found query: %.3f%n",
                totalMatches / (double) foundQueries
            );
        }
    }

    private static List<String> generateSearchQueries(int numSearches, int difficulty) {
        List<String> queries = new ArrayList<>();
        SecureRandom random = new SecureRandom();
        for (int i = 0; i < numSearches; i++) {
            StringBuilder query = new StringBuilder();
            for (int j = 0; j < difficulty; j++) {
                query.append(String.format("%x", random.nextInt(16)));
            }
            queries.add(query.toString());
        }
        return queries;
    }

    private static String bytesToHexPrefix(byte[] bytes, int numHexChars) {
        StringBuilder sb = new StringBuilder();
        int bytesNeeded = (numHexChars + 1) / 2;
        for (int i = 0; i < Math.min(bytesNeeded, bytes.length); i++) {
            sb.append(String.format("%02x", bytes[i] & 0xFF));
        }
        return sb.substring(0, Math.min(numHexChars, sb.length()));
    }

    private static String bytesToHex(byte[] bytes, int offset, int length) {
        StringBuilder sb = new StringBuilder();
        for (int i = offset; i < Math.min(offset + length, bytes.length); i++) {
            sb.append(String.format("%02x", bytes[i] & 0xFF));
        }
        return sb.toString();
    }

    static class Result implements Serializable {
        String query;
        String fullHash;
        String nonce;
        boolean found;
    }
}
