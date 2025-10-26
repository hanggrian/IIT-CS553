#include <chrono>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <random>
#include <thread>
#include <blake3.h>
#include <boost/program_options.hpp>
#include "colors.hpp"
#include "generating.hpp"
#include "printing.hpp"
#include "record.hpp"
#include "searching.hpp"
#include "sorting.hpp"
#include "verifying.hpp"

using namespace std;
using namespace chrono;
using namespace boost::program_options;

constexpr string DEFAULT_APPROACH = "for";
const unsigned int DEFAULT_THREADS = thread::hardware_concurrency();
constexpr unsigned int DEFAULT_IO_THREADS = 1;
constexpr unsigned int DEFAULT_MEMORY = 1024;
constexpr unsigned int DEFAULT_EXPONENT = 26;
constexpr string DEFAULT_TMPNAME = "memo";
constexpr string DEFAULT_OUTFILE = "out.x";
constexpr bool DEFAULT_DEBUG = false;
constexpr bool DEFAULT_VERIFY = false;
constexpr unsigned int DEFAULT_PRINT_N = 0;
constexpr unsigned int DEFAULT_SEARCHES = 0;
constexpr unsigned int DEFAULT_DIFFICULTY = 0;

namespace {
    struct Options {
        string approach = DEFAULT_APPROACH;
        unsigned int threads = DEFAULT_THREADS;
        unsigned int io_threads = DEFAULT_IO_THREADS;
        unsigned int memory = DEFAULT_MEMORY;
        unsigned int exponent = DEFAULT_EXPONENT;
        string outfile = DEFAULT_OUTFILE;
        string tmpname = DEFAULT_TMPNAME;
        bool debug = DEFAULT_DEBUG;
        bool verify = DEFAULT_VERIFY;
        unsigned int print_n = DEFAULT_PRINT_N;
        unsigned int searches = DEFAULT_SEARCHES;
        unsigned int difficulty = DEFAULT_DIFFICULTY;
    };
}

int main(const int argc, char **argv) {
    options_description desc("Options");
    desc.add_options()
            (
                "approach,a",
                value<string>()->default_value(DEFAULT_APPROACH),
                "Parallelization mode"
            )
            (
                "threads,t",
                value<unsigned int>()->default_value(DEFAULT_THREADS),
                "Hashing threads"
            )
            (
                "iothreads,i",
                value<unsigned int>()->default_value(DEFAULT_IO_THREADS),
                "Number of I/O threads to use"
            )
            (
                "exponent,k",
                value<unsigned int>()->default_value(DEFAULT_EXPONENT),
                "Exponent k for 2^k iterations"
            )
            (
                "memory,m",
                value<unsigned int>()->default_value(DEFAULT_MEMORY),
                "Memory size in MB"
            )
            (
                "file,f",
                value<string>()->default_value(DEFAULT_OUTFILE),
                "Final output file"
            )
            (
                "file_temp,g",
                value<string>()->default_value(DEFAULT_TMPNAME),
                "Temporary file"
            )
            (
                "debug,d",
                bool_switch()->default_value(DEFAULT_DEBUG),
                "Enable per-search debug prints"
            )
            (
                "verify,v",
                bool_switch()->default_value(DEFAULT_VERIFY),
                "Enable file verification"
            )
            (
                "print,p",
                value<unsigned int>()->default_value(DEFAULT_PRINT_N),
                "Print N records and exit"
            )
            (
                "search,s",
                value<unsigned int>()->default_value(DEFAULT_SEARCHES),
                "Enable search of specified number of records"
            )
            (
                "difficulty,q",
                value<unsigned int>()->default_value(DEFAULT_DIFFICULTY),
                "Set difficulty for search in bytes"
            )
            ("help,h", "Display this help message");

    variables_map variables;
    try {
        store(
            parse_command_line(argc, argv, desc),
            variables
        );
        notify(variables);
    } catch (exception &e) {
        cerr << e.what() << "\n" << desc << "\n";
        exit(1);
    }
    if (variables.contains("help")) {
        cout << desc << "\n";
        exit(0);
    }

    Options options;
    options.approach = variables["approach"].as<string>();
    options.threads = variables["threads"].as<unsigned int>();
    options.io_threads = variables["iothreads"].as<unsigned int>();
    options.memory = variables["memory"].as<unsigned int>();
    options.exponent = variables["exponent"].as<unsigned int>();
    options.outfile = variables["file"].as<string>();
    options.tmpname = variables["file_temp"].as<string>();
    options.debug = variables["debug"].as<bool>();
    options.verify = variables["verify"].as<bool>();
    options.print_n = variables["print"].as<unsigned int>();
    options.searches = variables["search"].as<unsigned int>();
    options.difficulty = variables["difficulty"].as<unsigned int>();

    cout <<
            "Selected approach:          " <<
            BOLD <<
            options.approach <<
            END <<
            "\n";
    cout <<
            "Number of threads:          " <<
            BOLD <<
            options.threads <<
            END <<
            "\n";
    cout <<
            "IO threads:                 " <<
            BOLD <<
            options.io_threads <<
            END <<
            "\n";
    cout <<
            "Memory (MB):                " <<
            BOLD <<
            options.memory <<
            END <<
            "\n";
    cout <<
            "Parsed k:                   " <<
            BOLD <<
            options.exponent <<
            END <<
            "\n";
    cout <<
            "Size of HASH:               " <<
            BOLD <<
            NONCE_SIZE <<
            END <<
            "\n";
    cout <<
            "Size of NONCE:              " <<
            BOLD <<
            HASH_SIZE <<
            END <<
            "\n";

    if (options.print_n > 0) {
        if (!filesystem::exists(options.outfile)) {
            cerr <<
                    RED <<
                    "Final file not found: " <<
                    options.outfile <<
                    END <<
                    "\n";
            return 1;
        }
        print_file_samples(options.outfile, options.print_n);
        return 0;
    }

    // verify-only
    if (options.verify && options.searches == 0) {
        if (!filesystem::exists(options.outfile)) {
            cerr <<
                    RED <<
                    "File not found: " <<
                    options.outfile <<
                    END <<
                    "\n";
            return 1;
        }
        verify_file(options.outfile, options.debug);
        return 0;
    }

    // compute totals
    if (options.exponent >= 64) {
        cerr <<
                RED <<
                "k too large for 64-bit nonce generation." <<
                END <<
                "\n";
        return 1;
    }
    uint64_t total_records = 1ULL << options.exponent;
    const uint64_t total_bytes = total_records * RECORD_SIZE;
    cout <<
            "Computed total records:     " <<
            BOLD <<
            total_records <<
            END <<
            " (total bytes = " <<
            BOLD <<
            total_bytes <<
            END <<
            ")\n";

    // search-only
    if (options.searches > 0 && !options.verify) {
        if (!filesystem::exists(options.outfile)) {
            cerr << "File not found: " << options.outfile << "\n";
            return 1;
        }
        mt19937_64 rng(123456);
        uint64_t found = 0;
        uint64_t notfound = 0;
        uint64_t total_matches = 0;
        const auto t0 = steady_clock::now();
        for (int s = 0; s < options.searches; ++s) {
            const uint64_t pick_nonce = rng() % total_records;
            uint8_t nonce_buf[NONCE_SIZE];
            uint64_to_nonce(pick_nonce, nonce_buf);
            blake3_hasher hasher;
            blake3_hasher_init(&hasher);
            blake3_hasher_update(&hasher, nonce_buf, NONCE_SIZE);
            uint8_t out32[32];
            blake3_hasher_finalize(&hasher, out32, sizeof(out32));
            uint8_t target[HASH_SIZE];
            memcpy(target, out32, HASH_SIZE);
            if (options.difficulty >= 4) {
                target[0] ^= 0xFF;
            }
            if (options.difficulty >= 5) {
                for (unsigned char &i: target) {
                    i = static_cast<uint8_t>(rng() & 0xFF);
                }
            }
            auto matches = search_in_file(options.outfile, target);
            total_matches = matches.size();
            if (matches.empty()) {
                ++notfound;
            } else {
                ++found;
            }
            cout <<
                    "[" <<
                    s <<
                    "] " <<
                    (matches.empty() ? YELLOW : GREEN) <<
                    (matches.empty() ? "NOTFOUND" : "MATCH") <<
                    END <<
                    "\n";
        }
        const auto t1 = steady_clock::now();
        const double secs = duration_cast<duration<double> >(t1 - t0).count();

        cout <<
                GREEN <<
                "Search summary:    " <<
                "requested=" <<
                options.searches <<
                " performed=" <<
                options.searches <<
                " found_queries=" <<
                found <<
                " total_matches=" <<
                total_matches <<
                END <<
                "\n";
        cout <<
                GREEN <<
                "Total search time: " <<
                BOLD <<
                secs <<
                END <<
                GREEN <<
                " seconds" <<
                END <<
                "\n";
        return 0;
    }

    // Main pipeline: generate sorted chunk files then merge
    const string tmp_dir = options.tmpname + "_chunks";
    const uint64_t mem_bytes =
            static_cast<uint64_t>(options.memory) * 1024ULL * 1024ULL;
    uint64_t chunk_records = max<uint64_t>(1, mem_bytes / RECORD_SIZE);
    if (chunk_records > total_records) {
        chunk_records = total_records;
    }
    cout <<
            "Chunk records (per sorted): " <<
            BOLD <<
            chunk_records <<
            END <<
            "\n";
    const uint64_t num_chunks =
            (total_records + chunk_records - 1) / chunk_records;
    cout << "Number of chunks:           " << BOLD << num_chunks << END << "\n";

    // generate
    vector<string> chunk_files;
    GeneratedStats stats;
    auto t0 = steady_clock::now();
    generate_chunks(
        total_records,
        chunk_records,
        options.threads,
        options.io_threads,
        tmp_dir,
        chunk_files,
        options.approach,
        options.debug,
        stats
    );

    // merge
    cout <<
            YELLOW <<
            "Merging " <<
            chunk_files.size() <<
            " chunks into " <<
            options.outfile <<
            "..." <<
            END <<
            "\n";
    k_way_merge(chunk_files, options.outfile);

    // cleanup
    for (auto &p: chunk_files) {
        try {
            filesystem::remove(p);
        } catch (...) {
        }
    }
    try {
        filesystem::remove_all(tmp_dir);
    } catch (...) {
    }

    auto t1 = steady_clock::now();
    double total_secs = duration_cast<duration<double> >(t1 - t0).count();
    double throughput_mbps =
            (total_bytes / (1024.0 * 1024.0)) /
            (total_secs > 0 ? total_secs : 1e-9);
    double throughput_mh =
            (total_records / 1e6) / (total_secs > 0 ? total_secs : 1e-9);
    cout <<
            GREEN <<
            "Total throughput:           " <<
            BOLD <<
            throughput_mh <<
            END <<
            GREEN <<
            " MH/s " <<
            BOLD <<
            throughput_mbps <<
            END <<
            GREEN <<
            " MB/s" <<
            END <<
            "\n";
    cout <<
            GREEN <<
            "Total time:                 " <<
            BOLD <<
            total_secs <<
            END <<
            GREEN <<
            " seconds" <<
            END <<
            "\n";

    if (options.verify) {
        verify_file(options.outfile, options.debug);
    }
    return 0;
}
