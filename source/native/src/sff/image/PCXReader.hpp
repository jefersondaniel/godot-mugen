#ifndef PCX_READER_H
#define PCX_READER_H

#include "RawImage.hpp"
#include "../data/ByteArray.hpp"
#include "../data/ByteArrayStream.hpp"

using namespace godot;

class PCXReader {
private:
    ByteArray source;
public:
    PCXReader(ByteArray &source_);
    bool read(RawImage* outImage);
};

#endif
