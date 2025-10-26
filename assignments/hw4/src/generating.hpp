#pragma once

#include "record.hpp"

using namespace std;

struct GeneratedStats {
    atomic<uint64_t> generated{0};
};

void fill_hashes_range(
    uint64_t start_nonce,
    uint64_t count,
    Record *out_array,
    atomic<uint64_t> *progress = nullptr
);

void generate_chunks(
    uint64_t total_records,
    uint64_t chunk_records,
    int unsigned threads,
    unsigned int io_threads,
    const string &tmp_dir,
    vector<string> &out_chunk_files,
    const string &approach,
    bool debug,
    GeneratedStats &stats
);
