#ifndef PCX_IMAGE_H
#define PCX_IMAGE_H

#include <Godot.hpp>
#include <Image.hpp>
#include "ByteArray.hpp"

using namespace godot;

class PCXImage {
private:
    int _w, _h;
    ByteArray _pixels;
    ByteArray _colorTable;
public:
    PCXImage();
    PCXImage(ByteArray &pixels, int w, int h, ByteArray &colorTable);
    int width() const;
    int height() const;
    ByteArray pixels() const;
    ByteArray colorTable() const;
    void setColorTable(ByteArray &pal);
    Image* createImage();
    void operator=(const PCXImage &p_other);
    bool operator==(const PCXImage &p_other);
};

#endif
