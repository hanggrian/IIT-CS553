package edu.illinoistech.hawk.hwijaya;

import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;

public class HadoopVerify {
    public static void main(String[] args) {
        Configuration conf = new Configuration();

        try {
            Job job = Job.getInstance(conf, "hadoop-verify");
            job.setJarByClass(HadoopVerify.class);
            job.setMapperClass(VerifyMapper.class);
            job.setNumReduceTasks(0);

            job.setInputFormatClass(SequenceFileInputFormat.class);
            SequenceFileInputFormat.addInputPaths(job, args[0]);

            job.setOutputKeyClass(BytesWritable.class);
            job.setOutputValueClass(NullWritable.class);

            System.exit(
                job.waitForCompletion(true)
                    ? (
                    job.getCounters().findCounter("VERIFY", "UNSORTED").getValue() == 0
                        ? 0
                        : 1
                ) : 1
            );
        } catch (IOException | InterruptedException | ClassNotFoundException e) {
            System.out.print(e.getMessage());
        }
    }

    public static class VerifyMapper
        extends Mapper<BytesWritable, NullWritable, BytesWritable, NullWritable> {
        private byte[] prev = null;

        @Override
        protected void map(BytesWritable key, NullWritable value, Context context) {
            byte[] current = key.getBytes();
            if (prev != null) {
                for (int i = 0; i < Hashes.RECORD_BYTES; i++) {
                    if ((prev[i] & 0xFF) > (current[i] & 0xFF)) {
                        context.getCounter("VERIFY", "UNSORTED").increment(1);
                        return;
                    }
                    if ((prev[i] & 0xFF) < (current[i] & 0xFF)) {
                        break;
                    }
                }
            }
            prev = new byte[Hashes.RECORD_BYTES];
            System.arraycopy(current, 0, prev, 0, Hashes.RECORD_BYTES);
        }
    }
}
