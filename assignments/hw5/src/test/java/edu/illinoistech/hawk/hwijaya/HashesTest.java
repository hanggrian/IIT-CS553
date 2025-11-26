package edu.illinoistech.hawk.hwijaya;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.stream.IntStream;

import static com.google.common.truth.Truth.assertThat;

public class HashesTest {
    private static final int THREAD_COUNT = 10;

    private final ExecutorService executor = Executors.newFixedThreadPool(THREAD_COUNT);

    @Test
    public void generate() {
        assertThat(Hashes.generate())
            .isNotEmpty();
    }

    @Test
    void uniqueInstanceForEachThread() throws InterruptedException {
        ConcurrentHashMap<Thread, Object> blakes = new ConcurrentHashMap<>();
        IntStream
            .range(0, THREAD_COUNT)
            .forEach(i ->
                executor.submit(() -> {
                    blakes.put(Thread.currentThread(), Hashes.BLAKE_PROVIDER.get());
                    Hashes.BLAKE_PROVIDER.remove();
                })
            );
        executor.shutdown();
        executor.awaitTermination(5, TimeUnit.SECONDS);

        assertThat(blakes.size())
            .isEqualTo(THREAD_COUNT);
        assertThat(blakes.values().stream().distinct().count())
            .isEqualTo(THREAD_COUNT);
    }

    @AfterEach
    public void cleanup() {
        Hashes.BLAKE_PROVIDER.remove();
    }
}
