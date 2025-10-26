#include <cstring>
#include <filesystem>
#include <fstream>
#include <memory>
#include <optional>
#include <queue>
#include <vector>
#include "record.hpp"
#include "sorting.hpp"

using namespace std;

struct FileReader {
    ifstream stream;
    vector<Record> buffer;
    size_t buf_pos = 0;
    size_t buf_size = 0;
    size_t capacity = 1 << 16;
    bool eof = false;

    explicit FileReader(
        const string &path,
        const size_t cap_records = 1 << 16
    ) : stream(path, ios::binary),
        capacity(cap_records) {
        if (!stream) {
            throw runtime_error("Cannot open chunk file for read: " + path);
        }
        buffer.resize(capacity);
        refill();
    }

    void refill() {
        if (eof) {
            return;
        }
        stream.read(
            reinterpret_cast<char *>(buffer.data()),
            capacity * sizeof(Record)
        );
        buf_size = stream.gcount() / sizeof(Record);
        buf_pos = 0;
        if (buf_size == 0) {
            eof = true;
        }
    }

    optional<Record> pop() {
        if (buf_pos < buf_size) {
            return buffer[buf_pos++];
        }
        if (eof) {
            return nullopt;
        }
        refill();
        if (buf_pos < buf_size) {
            return buffer[buf_pos++];
        }
        return nullopt;
    }
};

struct HeapItem {
    Record record;
    size_t reader_idx;
};

struct HeapCmp {
    bool operator()(const HeapItem &a, const HeapItem &b) const {
        if (const int cmp = memcmp(a.record.hash, b.record.hash, HASH_SIZE);
            cmp != 0
        ) {
            return cmp > 0;
        }
        return memcmp(a.record.nonce, b.record.nonce, NONCE_SIZE) > 0;
    }
};

void k_way_merge(
    const vector<string> &chunk_files,
    const string &out_path
) {
    size_t k = chunk_files.size();
    vector<unique_ptr<FileReader> > readers;
    readers.reserve(k);
    for (auto &p: chunk_files) {
        readers.emplace_back(make_unique<FileReader>(p));
    }
    priority_queue<HeapItem, vector<HeapItem>, HeapCmp> queue;
    for (size_t i = 0; i < readers.size(); ++i) {
        if (auto opt = readers[i]->pop()) {
            queue.push(HeapItem{*opt, i});
        }
    }
    ofstream stream(out_path, ios::binary | ios::out);
    if (!stream) {
        throw runtime_error("Cannot open output file for write: " + out_path);
    }
    vector<Record> outbuf;
    outbuf.reserve(1 << 16);
    while (!queue.empty()) {
        auto [rec, reader_idx] = queue.top();
        queue.pop();
        outbuf.push_back(rec);
        if (outbuf.size() >= (1 << 16)) {
            stream.write(
                reinterpret_cast<const char *>(outbuf.data()),
                outbuf.size() * sizeof(Record)
            );
            outbuf.clear();
        }
        if (auto opt = readers[reader_idx]->pop()) {
            queue.push(HeapItem{*opt, reader_idx});
        }
    }
    if (!outbuf.empty()) {
        stream.write(
            reinterpret_cast<const char *>(outbuf.data()),
            outbuf.size() * sizeof(Record)
        );
        outbuf.clear();
    }
    stream.close();
}
