class PCXHEADER
{
  public:
    PCXHEADER();

    inline int width() const { return ( XMax-XMin ) + 1; }
    inline int height() const { return ( YMax-YMin ) + 1; }
    inline bool isCompressed() const { return ( Encoding==1 ); }

    uint8_t  Manufacturer;    // Constant Flag, 10 = ZSoft .pcx
    uint8_t  Version;         // Version information·
                              // 0 = Version 2.5 of PC Paintbrush·
                              // 2 = Version 2.8 w/palette information·
                              // 3 = Version 2.8 w/o palette information·
                              // 4 = PC Paintbrush for Windows(Plus for
                              //     Windows uses Ver 5)·
                              // 5 = Version 3.0 and > of PC Paintbrush
                              //     and PC Paintbrush +, includes
                              //     Publisher's Paintbrush . Includes
                              //     24-bit .PCX files·
    uint8_t  Encoding;        // 1 = .PCX run length encoding
    uint8_t  Bpp;             // Number of bits to represent a pixel
                              // (per Plane) - 1, 2, 4, or 8·
    uint16_t XMin;
    uint16_t YMin;
    uint16_t XMax;
    uint16_t YMax;
    uint16_t HDpi;
    uint16_t YDpi;
    Palette  ColorMap;
    uint8_t  Reserved;        // Should be set to 0.
    uint8_t  NPlanes;         // Number of color planes
    uint16_t BytesPerLine;    // Number of bytes to allocate for a scanline
                              // plane.  MUST be an EVEN number.  Do NOT
                              // calculate from Xmax-Xmin.·
    uint16_t PaletteInfo;     // How to interpret palette- 1 = Color/BW,
                              // 2 = Grayscale ( ignored in PB IV/ IV + )·
    uint16_t HScreenSize;     // Horizontal screen size in pixels. New field
                              // found only in PB IV/IV Plus
    uint16_t VScreenSize;     // Vertical screen size in pixels. New field
                              // found only in PB IV/IV Plus
};

PCXHEADER::PCXHEADER()
{
    Manufacturer = 0;
    Version = 0;
}

static ByteArrayStream &operator>>( ByteArrayStream &s, RawColor &pal )
{
    uint8_t r, g, b;
    s >> r >> g >> b;

    pal.r = r;
    pal.g = g;
    pal.b = b;

    return s;
}

static ByteArrayStream &operator>>( ByteArrayStream &s, Palette &pal )
{
    pal.colors.resize(16);

    for (int i=0; i<16; ++i)
        s >> pal.colors[i];

    return s;
}

static ByteArrayStream &operator>>( ByteArrayStream &s, PCXHEADER &ph )
{
  uint8_t m, ver, enc, bpp;
  s >> m >> ver >> enc >> bpp;
  ph.Manufacturer = m;
  ph.Version = ver;
  ph.Encoding = enc;
  ph.Bpp = bpp;
  uint16_t xmin, ymin, xmax, ymax;
  s >> xmin >> ymin >> xmax >> ymax;
  ph.XMin = xmin;
  ph.YMin = ymin;
  ph.XMax = xmax;
  ph.YMax = ymax;
  uint16_t hdpi, ydpi;
  s >> hdpi >> ydpi;
  ph.HDpi = hdpi;
  ph.YDpi = ydpi;
  Palette colorMap;
  uint8_t res, np;
  s >> colorMap >> res >> np;
  ph.ColorMap = colorMap;
  ph.Reserved = res;
  ph.NPlanes = np;
  uint16_t bytesperline;
  s >> bytesperline; ph.BytesPerLine = bytesperline;
  uint16_t paletteinfo;
  s >> paletteinfo; ph.PaletteInfo = paletteinfo;
  uint16_t hscreensize, vscreensize;
  s >> hscreensize; ph.HScreenSize = hscreensize;
  s >> vscreensize; ph.VScreenSize = vscreensize;

  // Skip the rest of the header
  uint8_t byte;
  while ( s.pos() < 128 )
    s >> byte;

  return s;
}
