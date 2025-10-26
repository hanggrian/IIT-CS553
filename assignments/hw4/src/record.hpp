#pragma once

#include <iomanip>
#include <sstream>
#include <string>

#ifndef NONCE_SIZE
#define NONCE_SIZE 6
#endif

#ifndef HASH_SIZE
#define HASH_SIZE 10
#endif

#define RECORD_SIZE (NONCE_SIZE + HASH_SIZE)

using namespace std;

#pragma pack(push,1)
struct Record {
    uint8_t hash[HASH_SIZE];
    uint8_t nonce[NONCE_SIZE];
};
#pragma pack(pop)

inline string bytes_to_hex(const uint8_t *b, const size_t n) {
    ostringstream oss;
    oss << hex << setfill('0');
    for (size_t i = 0; i < n; ++i) {
        oss << setw(2) << static_cast<int>(b[i]);
    }
    return oss.str();
}

inline void uint64_to_nonce(uint64_t v, uint8_t *out) {
    for (size_t i = 0; i < NONCE_SIZE; ++i) {
        out[NONCE_SIZE - 1 - i] = static_cast<uint8_t>(v & 0xFF);
        v >>= 8;
    }
}

inline uint64_t nonce_to_uint64(const uint8_t *nonce) {
    uint64_t x = 0;
    for (size_t i = 0; i < NONCE_SIZE; ++i) {
        x = (x << 8) | nonce[i];
    }
    return x;
}
