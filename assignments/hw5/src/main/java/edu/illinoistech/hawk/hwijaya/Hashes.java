package edu.illinoistech.hawk.hwijaya;

import org.apache.commons.codec.digest.Blake3;
import org.apache.commons.lang3.tuple.Pair;

import java.util.Random;

public final class Hashes {
    private Hashes() {}

    private static final int HASH_BYTES = 10;
    private static final int NONCE_BYTES = 6;
    public static final int RECORD_BYTES = HASH_BYTES + NONCE_BYTES;

    public static final ThreadLocal<Pair<Random, Blake3>> BLAKE_PROVIDER =
        ThreadLocal.withInitial(() -> Pair.of(new Random(), Blake3.initHash()));

    public static byte[] generate() {
        Pair<Random, Blake3> blake = BLAKE_PROVIDER.get();

        byte[] nonce = new byte[NONCE_BYTES];
        blake
            .getLeft()
            .nextBytes(nonce);

        byte[] hash = new byte[HASH_BYTES];
        blake
            .getRight()
            .reset()
            .update(nonce)
            .doFinalize(hash);

        byte[] record = new byte[RECORD_BYTES];
        System.arraycopy(hash, 0, record, 0, HASH_BYTES);
        System.arraycopy(nonce, 0, record, HASH_BYTES, NONCE_BYTES);
        return record;
    }
}
