package edu.illinoistech.hawk.hwijaya;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

public class HadoopSearch {
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: HadoopSearch <sortedDataPath> <numSearches> <difficulty>");
            System.exit(1);
        }

        String inputPath = args[0];
        int numSearches = Integer.parseInt(args[1]);
        int difficulty = Integer.parseInt(args[2]);

        if (difficulty < 1 || difficulty > 8) {
            System.err.println("Difficulty must be between 1 and 8");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        conf.setInt("num.searches", numSearches);
        conf.setInt("difficulty", difficulty);

        List<String> queries = generateSearchQueries(numSearches, difficulty);
        conf.setStrings("search.queries", queries.toArray(new String[0]));

        boolean success = false;
        try {
            Job job = Job.getInstance(conf, "hadoop-search");
            job.setJarByClass(HadoopSearch.class);
            job.setMapperClass(SearchMapper.class);
            job.setReducerClass(SearchReducer.class);
            job.setNumReduceTasks(1);
            job.setMapOutputKeyClass(Text.class);
            job.setMapOutputValueClass(Text.class);
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(Text.class);
            job.setInputFormatClass(SequenceFileInputFormat.class);
            job.setOutputFormatClass(TextOutputFormat.class);

            SequenceFileInputFormat.addInputPath(job, new Path(inputPath));
            TextOutputFormat.setOutputPath(job, new Path(inputPath + "_search_results"));

            long startTime = System.currentTimeMillis();
            success = job.waitForCompletion(true);
            long elapsed = System.currentTimeMillis() - startTime;

            if (!success) {
                System.exit(1);
            }

            long totalMatches =
                job.getCounters()
                    .findCounter(SearchCounter.TOTAL_MATCHES)
                    .getValue();
            long foundQueries =
                job.getCounters()
                    .findCounter(SearchCounter.FOUND_QUERIES)
                    .getValue();
            long notFoundQueries =
                job.getCounters()
                    .findCounter(SearchCounter.NOT_FOUND_QUERIES)
                    .getValue();
            long totalComparisons =
                job.getCounters()
                    .findCounter(SearchCounter.TOTAL_COMPARISONS)
                    .getValue();

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
            System.out.printf("Total comparisons: %d%n", totalComparisons);
            System.out.printf(
                "Avg comparisons per search: %.1f%n",
                totalComparisons / (double) numSearches
            );
            System.out.printf(
                "Avg matches per found query: %.3f%n",
                totalMatches / (double) foundQueries
            );
        } catch (IOException | InterruptedException | ClassNotFoundException e) {
            System.err.println("Error during search: " + e.getMessage());
        } finally {
            if (!success) {
                System.exit(1);
            }
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

    public enum SearchCounter {
        TOTAL_MATCHES,
        FOUND_QUERIES,
        NOT_FOUND_QUERIES,
        TOTAL_COMPARISONS
    }

    public static class SearchMapper
        extends Mapper<BytesWritable, NullWritable, Text, Text> {

        private String[] queries;
        private int difficulty;

        @Override
        protected void setup(Context context) {
            Configuration conf = context.getConfiguration();
            queries = conf.getStrings("search.queries");
            difficulty = conf.getInt("difficulty", 3);
        }

        @Override
        protected void map(BytesWritable key, NullWritable value, Context context)
            throws IOException, InterruptedException {
            byte[] record = new byte[key.getLength()];
            System.arraycopy(key.getBytes(), 0, record, 0, key.getLength());
            String recordPrefix = bytesToHexPrefix(record, difficulty);
            for (String query : queries) {
                context.getCounter(SearchCounter.TOTAL_COMPARISONS).increment(1);
                if (!recordPrefix.equals(query)) {
                    continue;
                }
                String fullHash = bytesToHex(record, 10);
                String nonce = bytesToHex(record, 10, 6);
                context.write(new Text(query), new Text(fullHash + " " + nonce));
            }
        }

        private String bytesToHexPrefix(byte[] bytes, int numHexChars) {
            StringBuilder sb = new StringBuilder();
            int bytesNeeded = (numHexChars + 1) / 2;
            for (int i = 0; i < Math.min(bytesNeeded, bytes.length); i++) {
                sb.append(String.format("%02x", bytes[i] & 0xFF));
            }
            return sb.substring(0, Math.min(numHexChars, sb.length()));
        }

        private String bytesToHex(byte[] bytes, int length) {
            return bytesToHex(bytes, 0, length);
        }

        private String bytesToHex(byte[] bytes, int offset, int length) {
            StringBuilder sb = new StringBuilder();
            for (int i = offset; i < Math.min(offset + length, bytes.length); i++) {
                sb.append(String.format("%02x", bytes[i] & 0xFF));
            }
            return sb.toString();
        }
    }

    public static class SearchReducer extends Reducer<Text, Text, Text, Text> {
        @Override
        protected void reduce(Text key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {
            boolean foundAny = false;
            int matchCount = 0;
            for (Text value : values) {
                foundAny = true;
                matchCount++;
                context.write(key, new Text("MATCH " + value.toString()));
            }
            if (foundAny) {
                context.getCounter(SearchCounter.FOUND_QUERIES).increment(1);
                context.getCounter(SearchCounter.TOTAL_MATCHES).increment(matchCount);
                return;
            }
            context.getCounter(SearchCounter.NOT_FOUND_QUERIES).increment(1);
            context.write(key, new Text("NOTFOUND"));
        }
    }
}
