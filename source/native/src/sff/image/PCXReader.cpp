#include <algorithm>
#include "PCXReader.hpp"
#include "structs.hpp"

static void readLine(ByteArrayStream& s, ByteArray& buf, const PCXHEADER& header)
{
    uint32_t i = 0;
    uint32_t size = buf.size();
    uint8_t byte, count;

    if (header.isCompressed()) {
        // Uncompress the image data
        while (i < size) {
            count = 1;
            s >> byte;
            if (byte > 0xc0) {
                count = byte - 0xc0;
                s >> byte;
            }
            while (count-- && i < size)
                buf[i++] = byte;
        }
    } else {
        // Image is not compressed (possible?)
        while (i < size) {
            s >> byte;
            buf[i++] = byte;
        }
    }
}

static void readImage1(RawImage& img, ByteArrayStream& s, const PCXHEADER& header)
{
    ByteArray buf(header.BytesPerLine, 0);

    img = RawImage(header.width(), header.height(), 2);

    for (int y = 0; y < header.height(); ++y) {
        if (s.atEnd()) {
            img = RawImage();
            return;
        }

        readLine(s, buf, header);
        uint8_t* p = img.scanLine(y);
        unsigned int bpl = std::min((uint16_t)((header.width() + 7) / 8), header.BytesPerLine);
        for (unsigned int x = 0; x < bpl; ++x)
            p[x] = buf[x];
    }

    // Set the color palette
    img.setColor(0, RawColor(0, 0, 0));
    img.setColor(1, RawColor(255, 255, 255));
}

static void readImage4(RawImage& img, ByteArrayStream& s, const PCXHEADER& header)
{
    ByteArray buf(header.BytesPerLine * 4, 0);
    ByteArray pixbuf(header.width(), 0);

    img = RawImage(header.width(), header.height(), 16);

    for (int y = 0; y < header.height(); ++y) {
        if (s.atEnd()) {
            img = RawImage();
            return;
        }

        pixbuf.fill(0);
        readLine(s, buf, header);

        for (int i = 0; i < 4; i++) {
            uint32_t offset = i * header.BytesPerLine;
            for (int x = 0; x < header.width(); ++x)
                if (buf[offset + (x / 8)] & (128 >> (x % 8)))
                    pixbuf[x] = (int)(pixbuf[x]) + (1 << i);
        }

        uint8_t* p = img.scanLine(y);
        for (int x = 0; x < header.width(); ++x)
            p[x] = pixbuf[x];
    }

    // Read the palette
    for (int i = 0; i < 16; ++i)
        img.setColor(i, header.ColorMap.colors[i]);
}

static void readImage8(RawImage& img, ByteArrayStream& s, const PCXHEADER& header)
{
    ByteArray buf(header.BytesPerLine, 0);

    img = RawImage(header.width(), header.height(), 256);

    for (int y = 0; y < header.height(); ++y) {
        if (s.atEnd()) {
            img = RawImage();
            return;
        }

        readLine(s, buf, header);

        uint8_t* p = img.scanLine(y);
        unsigned int bpl = std::min(header.BytesPerLine, (uint16_t)header.width());
        for (unsigned int x = 0; x < bpl; ++x)
            p[x] = buf[x];
    }

    uint8_t flag;
    s >> flag;

    if (flag == 12 && (header.Version == 5 || header.Version == 2)) {
        // Read the palette
        uint8_t r, g, b;
        for (int i = 0; i < 256; ++i) {
            s >> r >> g >> b;
            img.setColor(i, RawColor(r, g, b, i == 0 ? 0 : 255));
        }
    } else {
        cerr << "error: unsupported pcx, palette not set" << endl;
    }
}

static void readImage24(RawImage& img, ByteArrayStream& s, const PCXHEADER& header)
{
    // TODO: Implement 24 bit images
    cerr << "error: 24 bit pcx not implementend" << endl;
    img = RawImage();
    return;
    /*
    ByteArray r_buf(header.BytesPerLine, 0);
    ByteArray g_buf(header.BytesPerLine, 0);
    ByteArray b_buf(header.BytesPerLine, 0);

    img = RawImage(header.width(), header.height(), 0);

    for (int y = 0; y < header.height(); ++y) {
        if (s.atEnd()) {
            img = RawImage();
            return;
        }

        readLine(s, r_buf, header);
        readLine(s, g_buf, header);
        readLine(s, b_buf, header);

        uint32_t* p = img.scanLine(y);

        for (int x = 0; x < header.width(); ++x) {
            p[x] = qRgb(r_buf[x], g_buf[x], b_buf[x]);
        }
    }
    */
}

PCXReader::PCXReader(ByteArray &source_)
{
    source = source_;
}

bool PCXReader::read(RawImage* outImage)
{
    ByteArrayStream s(source);

    if (source.size() < 128) {
        return false;
    }

    PCXHEADER header;

    s >> header;

    if (header.Manufacturer != 10 || s.atEnd()) {
        return false;
    }

    RawImage img;

    if (header.Bpp == 1 && header.NPlanes == 1) {
        readImage1(img, s, header);
    }
    else if (header.Bpp == 1 && header.NPlanes == 4) {
        readImage4(img, s, header);
    }
    else if (header.Bpp == 8 && header.NPlanes == 1) {
        readImage8(img, s, header);
    }
    else if (header.Bpp == 8 && header.NPlanes == 3) {
        readImage24(img, s, header);
    }

    if (img.pixels().size() > 0) {
        *outImage = img;
        return true;
    }
    else {
        return false;
    }
}
