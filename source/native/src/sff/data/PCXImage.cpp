#include "PCXImage.hpp"

PCXImage::PCXImage()
{
    _w = 0;
    _h = 0;
}

PCXImage::PCXImage(ByteArray &pixels, int w, int h, ByteArray &colorTable)
{
    _w = w;
    _h = h;
    _pixels = pixels;
    _colorTable = colorTable;
}

int PCXImage::width() const
{
    return _w;
}

int PCXImage::height() const
{
    return _h;
}

ByteArray PCXImage::colorTable() const
{
    return _colorTable;
}

ByteArray PCXImage::pixels() const
{
    return _pixels;
}

void PCXImage::setColorTable(ByteArray &pal)
{
    _colorTable = pal;
}

Image* PCXImage::createImage()
{
    ByteArray dest;

    dest.resize(_w * _h * 4);

    const uint32_t* p_colors = reinterpret_cast<const uint32_t*>(_colorTable.ptr());
    uint32_t* p_image = reinterpret_cast<uint32_t*>(dest.ptr());

    for (int i = 0; i < (_w * _h); i++) {
        p_image[i] = p_colors[_pixels[i]];
    }

    Image* image = Image::_new();
    image->create_from_data(_w, _h, false, Image::Format::FORMAT_RGBA8, dest);

    return image;
}

void PCXImage::operator=(const PCXImage &p_other)
{
    _w = p_other.width();
    _h = p_other.height();
    _pixels = p_other.pixels();
    _colorTable = p_other.colorTable();
}

bool PCXImage::operator==(const PCXImage &p_other)
{
    return p_other.colorTable() == colorTable() && p_other.pixels() == pixels();
}
