/*
 * Nomen - a New Opensource Mugen Editor by Nobun
 *
 *
 *  Copyright (C) 2011  Nobun
 *  http://mugenrebirth.forumfree.it
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program (GPL.txt).  If not, see <http://www.gnu.org/licenses/>.
 *
 ******************************************************/

// SFFv2 INTERNAL ONLY. DON'T USE THIS HEADER OUTSIDE sffv2

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

  long first_sprnode_offset;
  long total_frames;
  long first_palnode_offset;
  long total_palettes;
  long ldata_offset;
  long ldata_length;
  long tdata_offset;
  long tdata_length;
  char reserved5[4]; //4 bytes = 0
  char reserved6[4]; //4 bytes = 0
  char unused[436]; //436 bytes = 0
};


struct _SFFV2_SPRITE_NODE_HEADER {
  short groupno;
  short imageno;
  short w; //dimensioni immagini: w
  short h; //dimensioni immagini: h
  short x;
  short y;
  short linked;
  unsigned char fmt; //0=raw, 1=invalid, 2=RLE8, 3=RLE5, 4=LZ5
  unsigned char colordepth;
  long offset; //offset into ldata or tdata
  long len; //length of image
  short palindex;
  short flags; //bit0 = 0 ldata; bit0 = 1 tdata
};


struct _SFFV2_PAL_NODE_HEADER {
  short groupno;
  short itemno;
  short numcols;
  short linked;
  long offset; //offset into ldata
  long len; //len=0 => palette linked
};




DataStream &operator>>( DataStream &ds, _SFFV2_SFF_HEADER &header )
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


DataStream &operator<<( DataStream &ds, const _SFFV2_SFF_HEADER &header )
{
  ds.writeRawData((char *) &header.signature, 12);
  ds<<header.verlo3; ds<<header.verlo2; ds<<header.verlo1; ds<<header.verhi;
  ds.writeRawData((char *) &header.reserved1, 4);
  ds.writeRawData((char *) &header.reserved2, 4);

  ds<<header.compatverlo3;
  ds<<header.compatverlo2;
  ds<<header.compatverlo1;
  ds<<header.compatverhi;
  ds.writeRawData((char *) &header.reserved3, 4);
  ds.writeRawData((char *) &header.reserved4, 4);

  ds.writeRawData((char *) &header.first_sprnode_offset,4);
  ds.writeRawData((char *) &header.total_frames, 4);
  ds.writeRawData((char *) &header.first_palnode_offset, 4);
  ds.writeRawData((char *) &header.total_palettes, 4);
  ds.writeRawData((char *) &header.ldata_offset, 4);
  ds.writeRawData((char *) &header.ldata_length, 4);
  ds.writeRawData((char *) &header.tdata_offset, 4);
  ds.writeRawData((char *) &header.tdata_length, 4);
  ds.writeRawData((char *) &header.reserved4, 4);
  ds.writeRawData((char *) &header.reserved5, 4);
  ds.writeRawData((char *) &header.unused, 436);
  return ds;
}


DataStream &operator>>( DataStream &ds, _SFFV2_SPRITE_NODE_HEADER &spr )
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


DataStream &operator<<( DataStream &ds, const _SFFV2_SPRITE_NODE_HEADER &spr )
{
  ds.writeRawData((char *) &spr.groupno, 2);
  ds.writeRawData((char *) &spr.imageno, 2);
  ds.writeRawData((char *) &spr.w, 2); //dimensioni immagini: w
  ds.writeRawData((char *) &spr.h, 2); //dimensioni immagini: h
  ds.writeRawData((char *) &spr.x, 2);
  ds.writeRawData((char *) &spr.y, 2);
  ds.writeRawData((char *) &spr.linked, 2);
  ds<<spr.fmt; //0=raw, 1=invalid, 2=RLE8, 3=RLE5, 4=LZ5
  ds<<spr.colordepth;
  ds.writeRawData((char *) &spr.offset, 4); //offset into ldata or tdata
  ds.writeRawData((char *) &spr.len, 4); //length of image
  ds.writeRawData((char *) &spr.palindex, 2);
  ds.writeRawData((char *) &spr.flags, 2); //bit0 = 0 ldata; bit0 = 1 tdata
  return ds;
}


DataStream &operator>>( DataStream &ds, _SFFV2_PAL_NODE_HEADER &pal )
{
  ds.readRawData((char *) &pal.groupno, 2);
  ds.readRawData((char *) &pal.itemno, 2);
  ds.readRawData((char *) &pal.numcols, 2);
  ds.readRawData((char *) &pal.linked, 2);
  ds.readRawData((char *) &pal.offset, 4); //offset into ldata
  ds.readRawData((char *) &pal.len, 4); //len=0 => palette linked
  return ds;
}


DataStream &operator<<( DataStream &ds, _SFFV2_PAL_NODE_HEADER &pal )
{
  ds.writeRawData((char *) &pal.groupno, 2);
  ds.writeRawData((char *) &pal.itemno, 2);
  ds.writeRawData((char *) &pal.numcols, 2);
  ds.writeRawData((char *) &pal.linked, 2);
  ds.writeRawData((char *) &pal.offset, 4); //offset into ldata
  ds.writeRawData((char *) &pal.len, 4); //len=0 => palette linked
  return ds;
}

