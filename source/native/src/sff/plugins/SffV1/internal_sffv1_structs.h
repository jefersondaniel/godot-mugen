struct _SFFV1_SFF_HEADER {
  char signature[12];
  uint8_t verhi; //0
  uint8_t verlo; //1
  uint8_t verlo2; //0
  uint8_t verlo3; //1
  uint32_t numGroups;
  uint32_t numImages;
  uint32_t first_offset;
  uint32_t subheader_size; //=32
  bool isShared;
  char reserved[3];
  char comments[476];
};

struct _SFFV1_SFF_SPRITE_HEADER {
  uint32_t offsetNextSprite;
  uint32_t subfileLen;
  int16_t x;
  int16_t y;
  int16_t groupno;
  int16_t imageno;
  int16_t linked;
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
