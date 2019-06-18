#include "RawImage.hpp"

RawColor::RawColor() {
    r = 0;
    g = 0;
    b = 0;
    a = 1;
}

RawColor::RawColor(uint8_t _r, uint8_t _g, uint8_t _b) {
    r = _r;
    g = _g;
    b = _b;
    a = 1;
}

RawColor::RawColor(uint8_t _r, uint8_t _g, uint8_t _b, uint8_t _a) {
    r = _r;
    g = _g;
    b = _b;
    a = _a;
}

bool RawColor::operator==(const RawColor &p_other)
{
    return r == p_other.r && g == p_other.g && b == p_other.b && a == p_other.a;
}

void RawColor::operator=(const RawColor &p_other)
{
    r == p_other.r;
    g == p_other.g;
    b == p_other.b;
    a == p_other.a;
}

bool Palette::operator==(const Palette &p_other)
{
    if (p_other.colors.size() != colors.size()) {
        return false;
    }

    for (int i = 0; i < colors.size(); i++) {
        if ((colors[i] == p_other.colors[i]) == false) {
            return false;
        }
    }

    return true;
}

void Palette::operator=(const Palette &p_other)
{
    // pass
}

RawImage::RawImage()
{
    _w = 0;
    _h = 0;
}

RawImage::RawImage(int w, int h, int numColors)
{
    _w = w;
    _h = h;
    _pixels = ByteArray(w * h, 0);
    _colorTable.colors.resize(numColors);
}

RawImage::RawImage(ByteArray &pixels, int w, int h, Palette &colorTable)
{
    _w = w;
    _h = h;
    _pixels = pixels;
    _colorTable = colorTable;
}

int RawImage::width() const
{
    return _w;
}

int RawImage::height() const
{
    return _h;
}

Palette RawImage::colorTable() const
{
    return _colorTable;
}

ByteArray RawImage::pixels() const
{
    return _pixels;
}

void RawImage::setColorTable(Palette &pal)
{
    _colorTable = pal;
}

void RawImage::setPixels(ByteArray &pixels)
{
    _pixels = pixels;
}

void RawImage::setNumColors(int quantity)
{
    _colorTable.colors.resize(quantity);
}

void RawImage::setColor(int index, RawColor color)
{
    if (index >= _colorTable.colors.size()) {
        cerr << "invalid set color" << endl;
        return;
    }

    _colorTable.colors[index] = color;
}

uint8_t* RawImage::scanLine(int line)
{
    return &_pixels[width() * line];
}

Image* RawImage::createImage()
{
    ByteArray dest;

    dest.resize(_w * _h * 4);

    const uint32_t* p_colors = reinterpret_cast<const uint32_t*>(&_colorTable.colors.front());
    uint32_t* p_image = reinterpret_cast<uint32_t*>(dest.ptr());

    for (int i = 0; i < (_w * _h); i++) {
        p_image[i] = p_colors[_pixels[i]];
    }

    godot::Image* image = godot::Image::_new();
    image->create_from_data(_w, _h, false, godot::Image::Format::FORMAT_RGBA8, dest);

    return image;
}

void RawImage::operator=(const RawImage &p_other)
{
    _w = p_other.width();
    _h = p_other.height();
    _pixels = p_other.pixels();
    _colorTable = p_other.colorTable();
}

bool RawImage::operator==(const RawImage &p_other)
{
    return p_other.pixels() == pixels();
}
