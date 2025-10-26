#include <fstream>
#include <iostream>
#include "colors.hpp"
#include "record.hpp"
#include "printing.hpp"

using namespace std;

void print_file_samples(const string &path, const size_t max_print) {
    ifstream stream(path, ios::binary);
    if (!stream) {
        cerr << RED << "Cannot open file to print: " << path << END << "\n";
        return;
    }
    Record record{};
    size_t i = 0;
    while (i < max_print &&
        stream.read(reinterpret_cast<char *>(&record), sizeof(Record))
    ) {
        cout <<
                "[" <<
                i++ <<
                "] stored: " <<
                bytes_to_hex(record.hash, HASH_SIZE) <<
                " nonce: " <<
                bytes_to_hex(record.nonce, NONCE_SIZE) <<
                "\n";
    }
}
