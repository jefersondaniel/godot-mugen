#ifndef RAW_IMAGE_H
#define RAW_IMAGE_H

#include <Godot.hpp>
#include <Image.hpp>
#include <vector>
#include "../data/ByteArray.hpp"

using namespace std;

class RawColor {
public:
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
    RawColor();
    RawColor(uint8_t _r, uint8_t _g, uint8_t _b);
    RawColor(uint8_t _r, uint8_t _g, uint8_t _b, uint8_t _a);
    bool operator==(const RawColor &p_other);
    void operator=(const RawColor &p_other);
};

class Palette {
public:
    vector<RawColor> colors;
    bool operator==(const Palette &p_other);
    void operator=(const Palette &p_other);
};

class RawImage {
private:
    int _w, _h;
    ByteArray _pixels;
    Palette _colorTable;
public:
    RawImage();
    RawImage(int w, int h, int colors);
    RawImage(ByteArray &pixels, int w, int h, Palette &colorTable);
    int width() const;
    int height() const;
    ByteArray pixels() const;
    Palette colorTable() const;
    void setColorTable(Palette &pal);
    void setPixels(ByteArray &pixels);
    void setNumColors(int size);
    void setColor(int index, RawColor color);
    uint8_t* scanLine(int line);
    godot::Image* createImage();
    void operator=(const RawImage &p_other);
    bool operator==(const RawImage &p_other);
};

#endif
