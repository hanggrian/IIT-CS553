#pragma once

#include <vector>
#include "record.hpp"

using namespace std;

vector<Record> search_in_file(
    const string &path,
    const uint8_t target[HASH_SIZE]
);
