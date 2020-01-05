
struct _SFFV2_SFF_HEADER {
  char signature[12];
  unsigned char verlo3; //0
  unsigned char verlo2; //0
  unsigned char verlo1; //0
  unsigned char verhi;  //2
  char reserved1[4]; //4 bytes = 0
  char reserved2[4]; //4 bytes = 0

  unsigned char compatverlo3; //0
  unsigned char compatverlo2; //0
  unsigned char compatverlo1; //0
  unsigned char compatverhi; //2
  char reserved3[4];
  char reserved4[4];

  uint32_t first_sprnode_offset;
  uint32_t total_frames;
  uint32_t first_palnode_offset;
  uint32_t total_palettes;
  uint32_t ldata_offset;
  uint32_t ldata_length;
  uint32_t tdata_offset;
  uint32_t tdata_length;
  char reserved5[4]; //4 bytes = 0
  char reserved6[4]; //4 bytes = 0
  char unused[436]; //436 bytes = 0
};


struct _SFFV2_SPRITE_NODE_HEADER {
  int16_t groupno;
  int16_t imageno;
  int16_t w; //dimensioni immagini: w
  int16_t h; //dimensioni immagini: h
  int16_t x;
  int16_t y;
  int16_t linked;
  unsigned char fmt; //0=raw, 1=invalid, 2=RLE8, 3=RLE5, 4=LZ5
  unsigned char colordepth;
  uint32_t offset; //offset into ldata or tdata
  uint32_t len; //length of image
  int16_t palindex;
  int16_t flags; //bit0 = 0 ldata; bit0 = 1 tdata
};


struct _SFFV2_PAL_NODE_HEADER {
  int16_t groupno;
  int16_t itemno;
  int16_t numcols;
  int16_t linked;
  uint32_t offset; //offset into ldata
  uint32_t len; //len=0 => palette linked
};

FileStream &operator>>( FileStream &ds, _SFFV2_SFF_HEADER &header )
{
  ds.readRawData((char *) &header.signature, 12);
  ds>>header.verlo3; ds>>header.verlo2; ds>>header.verlo1; ds>>header.verhi;
  ds.readRawData((char *) &header.reserved1, 4);
  ds.readRawData((char *) &header.reserved2, 4);

  ds>>header.compatverlo3;
  ds>>header.compatverlo2;
  ds>>header.compatverlo1;
  ds>>header.compatverhi;
  ds.readRawData((char *) &header.reserved3, 4);
  ds.readRawData((char *) &header.reserved4, 4);

  ds.readRawData((char *) &header.first_sprnode_offset, 4);
  ds.readRawData((char *) &header.total_frames,4);
  ds.readRawData((char *) &header.first_palnode_offset, 4);
  ds.readRawData((char *) &header.total_palettes, 4);
  ds.readRawData((char *) &header.ldata_offset, 4);
  ds.readRawData((char *) &header.ldata_length, 4);
  ds.readRawData((char *) &header.tdata_offset, 4);
  ds.readRawData((char *) &header.tdata_length, 4);

  ds.readRawData((char *) &header.reserved5, 4);
  ds.readRawData((char *) &header.reserved6, 4);
  ds.readRawData((char *) &header.unused, 436);
  return ds;
}

FileStream &operator>>( FileStream &ds, _SFFV2_SPRITE_NODE_HEADER &spr )
{
  ds.readRawData((char *) &spr.groupno, 2);
  ds.readRawData((char *) &spr.imageno, 2);
  ds.readRawData((char *) &spr.w, 2); //dimensioni immagini: w
  ds.readRawData((char *) &spr.h, 2); //dimensioni immagini: h
  ds.readRawData((char *) &spr.x, 2);
  ds.readRawData((char *) &spr.y, 2);
  ds.readRawData((char *) &spr.linked, 2);
  ds>>spr.fmt; //0=raw, 1=invalid, 2=RLE8, 3=RLE5, 4=LZ5
  ds>>spr.colordepth;
  ds.readRawData((char *) &spr.offset, 4); //offset into ldata or tdata
  ds.readRawData((char *) &spr.len, 4); //length of image
  ds.readRawData((char *) &spr.palindex, 2);
  ds.readRawData((char *) &spr.flags, 2); //bit0 = 0 ldata; bit0 = 1 tdata
  return ds;
}

FileStream &operator>>( FileStream &ds, _SFFV2_PAL_NODE_HEADER &pal )
{
  ds.readRawData((char *) &pal.groupno, 2);
  ds.readRawData((char *) &pal.itemno, 2);
  ds.readRawData((char *) &pal.numcols, 2);
  ds.readRawData((char *) &pal.linked, 2);
  ds.readRawData((char *) &pal.offset, 4); //offset into ldata
  ds.readRawData((char *) &pal.len, 4); //len=0 => palette linked
  return ds;
}