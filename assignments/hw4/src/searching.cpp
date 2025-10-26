#include <cstring>
#include <fstream>
#include <iostream>
#include "searching.hpp"

using namespace std;

vector<Record> search_in_file(
    const string &path,
    const uint8_t target[HASH_SIZE]
) {
    ifstream stream(path, ios::binary);
    if (!stream) {
        throw runtime_error("Cannot open file for search");
    }
    stream.seekg(0, ios::end);
    uint64_t total_records =
            static_cast<uint64_t>(stream.tellg()) / sizeof(Record);
    if (total_records == 0) {
        return {};
    }
    uint64_t lo = 0;
    uint64_t hi = total_records - 1;
    auto read_record =
            [&](const uint64_t i)-> Record {
                Record record{};
                stream.seekg(sizeof(Record) * i, ios::beg);
                stream.read(reinterpret_cast<char *>(&record), sizeof(Record));
                return record;
            };
    bool found = false;
    uint64_t found_idx = 0;
    while (lo <= hi) {
        uint64_t mid = lo + (hi - lo) / 2;
        auto [hash, nonce] = read_record(mid);
        int c = memcmp(hash, target, HASH_SIZE);
        if (c == 0) {
            found = true;
            found_idx = mid;
            break;
        }
        if (c < 0) {
            lo = mid + 1;
            continue;
        }
        if (mid == 0) {
            break;
        }
        hi = mid - 1;
    }
    vector<Record> matches;
    if (!found) {
        return matches;
    }

    // scan backwards to first
    uint64_t i = found_idx;
    while (i > 0) {
        auto [hash, nonce] = read_record(i - 1);
        if (memcmp(hash, target, HASH_SIZE) != 0) {
            break;
        }
        --i;
    }

    // scan forward
    for (uint64_t j = i; j < total_records; ++j) {
        Record record = read_record(j);
        if (memcmp(record.hash, target, HASH_SIZE) != 0) {
            break;
        }
        matches.push_back(record);
    }
    return matches;
}
