package edu.illinoistech.hawk.hwijaya;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;

public class HadoopVault {
    private static final int DEFAULT_PARALLELISM = 32;

    public static void main(String[] args) {
        if (args.length != 4) {
            System.err.println(
                "Usage: HadoopVault <inputPath> <outputPath> <numRecords> <numReducers>"
            );
            return;
        }

        String inputPath = args[0];
        String outputPath = args[1];
        long numRecords = Long.parseLong(args[2]);
        int numReducers = Integer.parseInt(args[3]);

        Configuration conf = new Configuration();
        conf.setLong("records", numRecords);

        boolean success = false;
        try {
            Job job = Job.getInstance(conf, "hadoop-hashgen-sort");
            job.setJarByClass(HadoopVault.class);
            job.setMapperClass(HashGenMapper.class);
            job.setReducerClass(IdentityReducer.class);
            job.setNumReduceTasks(numReducers);
            job.setOutputKeyClass(BytesWritable.class);
            job.setOutputValueClass(NullWritable.class);
            job.setInputFormatClass(HashGenInputFormat.class);
            job.setOutputFormatClass(SequenceFileOutputFormat.class);
            job.setPartitionerClass(FirstBytePartitioner.class);

            FileInputFormat.addInputPath(job, new Path(inputPath));
            FileOutputFormat.setOutputPath(job, new Path(outputPath));

            long startTime = System.currentTimeMillis();
            success = job.waitForCompletion(true);
            System.out.printf(
                "Hadoop total time (sec): %.2f seconds%n",
                (System.currentTimeMillis() - startTime) / 1000.0
            );
        } catch (IOException | InterruptedException | ClassNotFoundException e) {
            System.out.println(e.getMessage());
        } finally {
            if (!success) {
                System.exit(1);
            }
        }
    }

    public static class HashGenMapper
        extends Mapper<NullWritable, NullWritable, BytesWritable, NullWritable> {
        private final BytesWritable outKey = new BytesWritable();

        @Override
        protected void map(NullWritable key, NullWritable value, Context context)
            throws IOException, InterruptedException {
            byte[] rec = Hashes.generate();
            outKey.set(rec, 0, Hashes.RECORD_BYTES);
            context.write(outKey, NullWritable.get());
        }
    }

    public static class IdentityReducer
        extends Reducer<BytesWritable, NullWritable, BytesWritable, NullWritable> {
        @Override
        protected void reduce(BytesWritable key, Iterable<NullWritable> values, Context context)
            throws IOException, InterruptedException {
            context.write(key, NullWritable.get());
        }
    }

    public static class FirstBytePartitioner extends Partitioner<BytesWritable, NullWritable> {
        @Override
        public int getPartition(BytesWritable key, NullWritable value, int numPartitions) {
            byte[] bytes = key.getBytes();
            if (bytes.length == 0) {
                return 0;
            }
            return (bytes[0] & 0xFF) % numPartitions;
        }
    }

    public static class HashGenInputFormat extends InputFormat<NullWritable, NullWritable> {
        @Override
        public List<InputSplit> getSplits(JobContext context) {
            Configuration conf = context.getConfiguration();
            long totalRecords = conf.getLong("records", 0);
            int numSplits = context.getNumReduceTasks() * 2;

            if (numSplits == 0) {
                numSplits = DEFAULT_PARALLELISM;
            }

            long recordsPerSplit = totalRecords / numSplits;
            long remainingRecords = totalRecords % numSplits;

            List<InputSplit> splits = new ArrayList<>(numSplits);
            long currentRecord = 0;
            for (int i = 0; i < numSplits; i++) {
                long length = recordsPerSplit + (i < remainingRecords ? 1 : 0);
                if (length <= 0) {
                    continue;
                }
                splits.add(new Split(currentRecord, length));
                currentRecord += length;
            }
            return splits;
        }

        @Override
        public RecordReader<NullWritable, NullWritable> createRecordReader(
            InputSplit split,
            TaskAttemptContext context
        ) {
            return new Reader();
        }

        public static class Split extends InputSplit implements Writable {
            private long startRecord;
            private long length;

            public Split() {}

            public Split(long startRecord, long length) {
                this.startRecord = startRecord;
                this.length = length;
            }

            @Override
            public long getLength() {
                return length;
            }

            @Override
            public String[] getLocations() {
                return new String[]{};
            }

            @Override
            public void write(DataOutput out) throws IOException {
                out.writeLong(startRecord);
                out.writeLong(length);
            }

            @Override
            public void readFields(DataInput in) throws IOException {
                startRecord = in.readLong();
                length = in.readLong();
            }
        }

        public static class Reader extends RecordReader<NullWritable, NullWritable> {
            private long totalRecords;
            private long records = 0;

            @Override
            public void initialize(InputSplit split, TaskAttemptContext context) {
                Split hashSplit = (Split) split;
                totalRecords = hashSplit.getLength();
            }

            @Override
            public boolean nextKeyValue() {
                if (records < totalRecords) {
                    records++;
                    return true;
                }
                return false;
            }

            @Override
            public NullWritable getCurrentKey() {
                return NullWritable.get();
            }

            @Override
            public NullWritable getCurrentValue() {
                return NullWritable.get();
            }

            @Override
            public float getProgress() {
                return totalRecords == 0 ? 0.0f : (float) records / totalRecords;
            }

            @Override
            public void close() {}
        }
    }
}
