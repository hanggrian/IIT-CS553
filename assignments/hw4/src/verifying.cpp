#include <chrono>
#include <cstring>
#include <fstream>
#include <iostream>
#include "colors.hpp"
#include "record.hpp"
#include "verifying.hpp"

using namespace std;
using namespace chrono;

void verify_file(const string &path, bool verbose) {
    ifstream stream(path, ios::binary);
    if (!stream) {
        cerr << RED << "Cannot open file for verify: " << path << END << "\n";
        return;
    }
    stream.seekg(0, ios::end);
    streampos fsz = stream.tellg();
    stream.seekg(0, ios::beg);
    uint64_t total_records = fsz / sizeof(Record);

    cout << "Size of '" << path << "' is " << fsz << " bytes.\n";
    constexpr size_t BUFSZ = 1 << 16;
    vector<Record> buf(BUFSZ);
    uint64_t processed = 0;
    Record prev{};
    bool has_prev = false;
    uint64_t not_sorted = 0;
    uint64_t zero_nonces = 0;

    auto t0 = steady_clock::now();
    while (processed < total_records) {
        size_t toread = min<uint64_t>(BUFSZ, total_records - processed);
        stream.read(
            reinterpret_cast<char *>(buf.data()),
            toread * sizeof(Record)
        );
        size_t actually = stream.gcount() / sizeof(Record);
        for (size_t i = 0; i < actually; ++i) {
            auto &r = buf[i];
            if (!has_prev) {
                prev = r;
                has_prev = true;
            } else {
                if (int cmp = memcmp(prev.hash, r.hash, HASH_SIZE); cmp > 0) {
                    ++not_sorted;
                }
                prev = r;
            }
            bool is_zero = true;
            for (unsigned char j: r.nonce) {
                if (j != 0) {
                    is_zero = false;
                    break;
                }
            }
            if (is_zero) {
                ++zero_nonces;
            }
        }
        processed += actually;
        if (!verbose) {
            continue;
        }
        auto now = steady_clock::now();
        double t = duration_cast<duration<double> >(now - t0).count();
        double mbps =
                (processed * sizeof(Record)) /
                (1024.0 * 1024.0) /
                (t > 0 ? t : 1e-9);
        cerr <<
                "[" <<
                t <<
                "] " <<
                YELLOW <<
                "Verifying... " <<
                static_cast<double>(processed) / total_records * 100.0 <<
                "%: " <<
                mbps <<
                " MB/s" <<
                END <<
                "\n";
    }
    auto t1 = steady_clock::now();
    double secs = duration_cast<duration<double> >(t1 - t0).count();
    cout <<
            GREEN <<
            "Verify summary:    " <<
            "sorted=" <<
            (total_records - not_sorted) <<
            " not_sorted=" <<
            not_sorted <<
            " zero_nonces=" <<
            zero_nonces <<
            " total_records=" <<
            total_records <<
            END <<
            "\n";
    cout <<
            GREEN <<
            "Total verify time: " <<
            BOLD <<
            secs <<
            END <<
            GREEN <<
            " seconds" <<
            END <<
            "\n";
}
