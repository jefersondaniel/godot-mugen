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

// SFFv1 INTERNAL ONLY. DON'T USE THIS HEADER OUTSIDE sffv1

struct _SFFV1_NOMEN_STRUCT {
  //this struct is used only internally by Nomen, during writing, to reoder image in the right
  //order for a good-working sffv1 file
  int palindex;
  vector<SffData> sffdata;
};


struct _SFFV1_SFF_HEADER {
  char signature[12];
  uint8_t verhi; //0
  uint8_t verlo; //1
  uint8_t verlo2; //0
  uint8_t verlo3; //1
  long numGroups;
  long numImages;
  long first_offset;
  long subheader_size; //=32
  bool isShared;
  char reserved[3];
  char comments[476];
};


struct _SFFV1_SFF_SPRITE_HEADER {
  long offsetNextSprite;
  long subfileLen;
  short x;
  short y;
  short groupno;
  short imageno;
  short linked;
  bool isShared;
  char blank[13];
};

FileStream &operator>>( FileStream &ds, _SFFV1_SFF_HEADER &header )
{
  ds.readRawData((char *) &header.signature, 12);
  ds>>header.verhi; ds>>header.verlo; ds>>header.verlo2; ds>>header.verlo3;
  ds.readRawData((char *) &header.numGroups, 4);
  ds.readRawData((char *) &header.numImages, 4);
  ds.readRawData((char *) &header.first_offset, 4);
  ds.readRawData((char *) &header.subheader_size, 4);
  {
    uint8_t tmp; ds>>tmp;
    if(tmp==0) header.isShared=false;
    if(tmp==1) header.isShared=true;
  }
  ds.readRawData((char *) &header.reserved, 3);
  ds.readRawData((char *) &header.comments, 476);
  return ds;
}

FileStream &operator>>( FileStream &ds, _SFFV1_SFF_SPRITE_HEADER &spr )
{
  ds.readRawData((char *) &spr.offsetNextSprite, 4);
  ds.readRawData((char *) &spr.subfileLen, 4);
  ds.readRawData((char *) &spr.x, 2);
  ds.readRawData((char *) &spr.y, 2);
  ds.readRawData((char *) &spr.groupno, 2);
  ds.readRawData((char *) &spr.imageno, 2);
  ds.readRawData((char *) &spr.linked, 2);
  {
	uint8_t tmp; ds>>tmp;
    if(tmp==0) spr.isShared=false;
	if(tmp==1) spr.isShared=true;
  }
  ds.readRawData((char *) &spr.blank, 13);
  return ds;
}
