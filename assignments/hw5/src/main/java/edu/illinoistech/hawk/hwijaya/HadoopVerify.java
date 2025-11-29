package edu.illinoistech.hawk.hwijaya;

import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.NullOutputFormat;

public class HadoopVerify {
    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Usage: HadoopVerify <sortedDataPath>");
            System.exit(1);
        }

        String inputPath = args[0];

        boolean success = false;
        try {
            Job job = Job.getInstance(new Configuration(), "hadoop-verify-sort");
            job.setJarByClass(HadoopVerify.class);
            job.setMapperClass(VerifyMapper.class);
            job.setReducerClass(VerifyReducer.class);
            job.setNumReduceTasks(1);
            job.setMapOutputKeyClass(BytesWritable.class);
            job.setMapOutputValueClass(NullWritable.class);
            job.setOutputKeyClass(NullWritable.class);
            job.setOutputValueClass(NullWritable.class);
            job.setInputFormatClass(SequenceFileInputFormat.class);
            job.setOutputFormatClass(NullOutputFormat.class);

            SequenceFileInputFormat.addInputPath(job, new Path(inputPath));

            long startTime = System.currentTimeMillis();
            success = job.waitForCompletion(true);
            long elapsed = System.currentTimeMillis() - startTime;
            if (!success) {
                return;
            }

            long errors = job.getCounters().findCounter(VerifyCounter.SORT_ERRORS).getValue();
            long records = job.getCounters().findCounter(VerifyCounter.TOTAL_RECORDS).getValue();

            System.out.printf("Total records verified: %,d%n", records);
            System.out.printf("Sort errors found: %,d%n", errors);
            System.out.printf("Verification time: %.2f seconds%n", elapsed / 1000.0);
        } catch (IOException | InterruptedException | ClassNotFoundException e) {
            System.err.println("Error during verification: " + e.getMessage());
        } finally {
            if (!success) {
                System.exit(1);
            }
        }
    }

    public enum VerifyCounter {
        SORT_ERRORS,
        TOTAL_RECORDS
    }

    public static class VerifyMapper
        extends Mapper<BytesWritable, NullWritable, BytesWritable, NullWritable> {

        @Override
        protected void map(BytesWritable key, NullWritable value, Context context)
            throws IOException, InterruptedException {
            context.write(key, value);
        }
    }

    public static class VerifyReducer
        extends Reducer<BytesWritable, NullWritable, NullWritable, NullWritable> {

        private byte[] previousRecord = null;
        private long recordCount = 0;
        private long errorCount = 0;

        @Override
        protected void reduce(BytesWritable key, Iterable<NullWritable> values, Context context) {
            byte[] currentRecord = new byte[key.getLength()];
            System.arraycopy(key.getBytes(), 0, currentRecord, 0, key.getLength());

            for (NullWritable value : values) {
                recordCount++;
                if (previousRecord != null) {
                    int comparison = compareBytes(previousRecord, currentRecord);
                    if (comparison > 0) {
                        errorCount++;
                        if (errorCount <= 10) {
                            System.err.printf(
                                "Sort error at record %,d: previous > current%n",
                                recordCount
                            );
                            System.err.printf("  Previous: %s%n", bytesToHex(previousRecord));
                            System.err.printf("  Current:  %s%n", bytesToHex(currentRecord));
                        }
                    }
                }
                previousRecord = currentRecord.clone();
            }
        }

        @Override
        protected void cleanup(Context context) {
            context.getCounter(VerifyCounter.TOTAL_RECORDS).increment(recordCount);
            context.getCounter(VerifyCounter.SORT_ERRORS).increment(errorCount);
        }

        private int compareBytes(byte[] a, byte[] b) {
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

        private String bytesToHex(byte[] bytes) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < Math.min(bytes.length, 16); i++) {
                sb.append(String.format("%02x", bytes[i]));
            }
            if (bytes.length > 16) {
                sb.append("...");
            }
            return sb.toString();
        }
    }
}
