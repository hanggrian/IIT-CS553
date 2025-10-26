#include <filesystem>
#include <fstream>
#include <iostream>
#include <thread>
#include <deque>
#include <blake3.h>
#include <boost/sort/sort.hpp>
#include <omp.h>
#include "colors.hpp"
#include "generating.hpp"

using namespace boost::sort;

static mutex cout_mutex;

static void compute_record(const uint64_t nonce, Record &rec) {
    uint64_to_nonce(nonce, rec.nonce);
    blake3_hasher hasher;
    blake3_hasher_init(&hasher);
    blake3_hasher_update(&hasher, rec.nonce, NONCE_SIZE);
    uint8_t out32[32];
    blake3_hasher_finalize(&hasher, out32, sizeof(out32));
    memcpy(rec.hash, out32, HASH_SIZE);
}

void fill_hashes_range(
    const uint64_t start_nonce,
    const uint64_t count,
    Record *out_array,
    atomic<uint64_t> *progress
) {
    for (uint64_t i = 0; i < count; ++i) {
        const uint64_t n = start_nonce + i;
        uint8_t nonce_buf[NONCE_SIZE];
        uint64_to_nonce(n, nonce_buf);
        blake3_hasher hasher;
        blake3_hasher_init(&hasher);
        blake3_hasher_update(&hasher, nonce_buf, NONCE_SIZE);
        uint8_t out[32];
        blake3_hasher_finalize(&hasher, out, sizeof(out));
        Record record{};
        memcpy(record.hash, out, HASH_SIZE);
        memcpy(record.nonce, nonce_buf, NONCE_SIZE);
        out_array[i] = record;
        if (progress) {
            ++*progress;
        }
    }
}

namespace {
    struct BufferQueue {
        deque<vector<Record> > q;
        mutex m;
        condition_variable cv;
        bool finished = false;
        size_t max_queue_size = 4;

        void push(vector<Record> &&v) {
            unique_lock lock(m);
            cv.wait(
                lock,
                [&] { return q.size() < max_queue_size || finished; }
            );
            if (!finished) {
                q.emplace_back(move(v));
            }
            lock.unlock();
            cv.notify_one();
        }

        bool pop(vector<Record> &out) {
            unique_lock lock(m);
            cv.wait(
                lock,
                [&] { return !q.empty() || finished; }
            );
            if (q.empty()) {
                return false;
            }
            out = move(q.front());
            q.pop_front();
            lock.unlock();
            cv.notify_all();
            return true;
        }

        void set_finished() {
            {
                lock_guard lock(m);
                finished = true;
            }
            cv.notify_all();
        }
    };

    bool record_less(const Record &a, const Record &b) {
        if (const int c = memcmp(a.hash, b.hash, HASH_SIZE); c != 0) {
            return c < 0;
        }
        return memcmp(a.nonce, b.nonce, NONCE_SIZE) < 0;
    }
}

void generate_chunks(
    uint64_t total_records,
    uint64_t chunk_records,
    unsigned int threads,
    unsigned int io_threads,
    const string &tmp_dir,
    vector<string> &out_chunk_files,
    const string &approach,
    bool debug,
    GeneratedStats &stats
) {
    filesystem::remove_all(tmp_dir);
    filesystem::create_directory(tmp_dir);

    uint64_t total_chunks = (total_records + chunk_records - 1) / chunk_records;

    if (approach != "task") {
        uint64_t offset = 0;
        unsigned int chunkId = 0;

        while (offset < total_records) {
            uint64_t chunks =
                min<uint64_t>(chunk_records, total_records - offset);
            vector<Record> buffer(chunks);

            vector<thread> workers;
            workers.reserve(threads);
            uint64_t per = chunks / threads;
            uint64_t extra = chunks % threads;
            uint64_t s = 0;

            for (unsigned int t = 0; t < threads; ++t) {
                uint64_t start = s;
                uint64_t end = s + per + (t < extra ? 1 : 0);
                if (start >= end) {
                    s = end;
                    continue;
                }

                workers.emplace_back([&buffer, offset, start, end] {
                    for (uint64_t i = start; i < end; i++) {
                        compute_record(offset + i, buffer[i]);
                    }
                });
                s = end;
            }
            for (auto &worker: workers) {
                worker.join();
            }

            parallel_stable_sort(buffer.begin(), buffer.end(), record_less);

            string chunk_file =
                    tmp_dir + "/chunk_" + to_string(chunkId++) + ".bin";
            {
                ofstream stream(chunk_file, ios::binary);
                stream.write(
                    reinterpret_cast<const char *>(buffer.data()),
                    sizeof(Record) * chunks
                );
            }

            if (debug) {
                lock_guard lock(cout_mutex);
                double percent = 100.0 * (offset + chunks) / total_records;
                cout <<
                        (percent >= 100.0 ? GREEN : YELLOW) <<
                        "Generating... " <<
                        percent <<
                        "%" <<
                        END <<
                        "\n";
            }

            out_chunk_files.push_back(move(chunk_file));
            stats.generated += chunks;
            offset += chunks;
        }
        return;
    }

    BufferQueue queue;
    atomic<uint64_t> written_chunks{0};
    mutex file_mutex;

    vector<thread> writers;
    writers.reserve(io_threads);

    for (unsigned int wi = 0; wi < io_threads; ++wi) {
        writers.emplace_back([&] {
            vector<Record> buf;
            buf.reserve(chunk_records);

            while (queue.pop(buf)) {
                parallel_stable_sort(buf.begin(), buf.end(), record_less);

                string chunk_file;
                {
                    unsigned int id;
                    lock_guard lock(file_mutex);
                    id = static_cast<unsigned int>(out_chunk_files.size());
                    chunk_file = tmp_dir + "/chunk_" + to_string(id) + ".bin";
                    out_chunk_files.push_back(chunk_file);
                }

                {
                    ofstream stream(chunk_file, ios::binary);
                    stream.write(
                        reinterpret_cast<const char *>(buf.data()),
                        sizeof(Record) * buf.size()
                    );
                }

                uint64_t current_written = ++written_chunks;
                stats.generated += buf.size();

                if (debug) {
                    lock_guard lock(cout_mutex);
                    double percent = 100.0 * current_written / total_chunks;
                    cout <<
                            (percent >= 100.0 ? GREEN : YELLOW) <<
                            "Writing... " <<
                            percent <<
                            "%" <<
                            END <<
                            "\n";
                }

                buf.clear();
            }
        });
    }

    omp_set_num_threads(static_cast<int>(threads));
    uint64_t offset = 0;
    uint64_t produced_chunks = 0;

    while (offset < total_records) {
        uint64_t chunks = min<uint64_t>(chunk_records, total_records - offset);
        vector<Record> buffer(chunks);

        #pragma omp parallel for schedule(static)
        for (int64_t i = 0; i < static_cast<int64_t>(chunks); ++i) {
            compute_record(offset + i, buffer[i]);
        }

        queue.push(move(buffer));
        ++produced_chunks;

        if (debug) {
            lock_guard lock(cout_mutex);
            cout <<
                    YELLOW <<
                    "Produced chunk " <<
                    produced_chunks <<
                    " (" <<
                    100.0 * (offset + chunks) / total_records <<
                    "%)" <<
                    END <<
                    "\n";
        }

        offset += chunks;
    }

    queue.set_finished();
    for (auto &writer: writers) {
        writer.join();
    }

    parallel_stable_sort(out_chunk_files.begin(), out_chunk_files.end());
}
