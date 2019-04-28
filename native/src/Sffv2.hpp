struct _SFFV2_SFF_HEADER {
  char signature[12];
  int8_t verlo3; //0
  int8_t verlo2; //0
  int8_t verlo1; //0
  int8_t verhi;  //2
  char reserved1[4]; //4 bytes = 0	
  char reserved2[4]; //4 bytes = 0
  
  int8_t compatverlo3; //0
  int8_t compatverlo2; //0
  int8_t compatverlo1; //0
  int8_t compatverhi; //2
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
  int8_t fmt; //0=raw, 1=invalid, 2=RLE8, 3=RLE5, 4=LZ5
  int8_t colordepth;
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

struct _SFFV2_RLE5_PACKET {
  uint8_t run_len;
  uint8_t color_bit;
  uint8_t data_len;
};

struct _SFFV2_LZ5_CONTROL_PACKET {
  uint8_t flags[8];
};


struct _SFFV2_LZ5_RLE_PACKET {
  uint8_t color;
  int numtimes; 
};


struct _SFFV2_LZ5_LZ_PACKET {
  int len;
  int offset;
  uint8_t recycled;
  uint8_t recycled_bits_filled;
  void reset() {
    recycled = 0;
    recycled_bits_filled = 0;
  }
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

PoolByteArrayStream &operator>>( PoolByteArrayStream &ds, _SFFV2_RLE5_PACKET &rle5 )
{
  ds>>rle5.run_len;
  {
    uint8_t byte_process;
    ds>>byte_process;
    rle5.color_bit = (byte_process & 0x80) /0x80; //1 if bit7 = 1; 0 if bit7 = 0
    rle5.data_len = byte_process & 0x7f; //value of bits 0-6
  }
  return ds;
}

PoolByteArrayStream &operator>>( PoolByteArrayStream &ds, _SFFV2_LZ5_CONTROL_PACKET &pack ) 
{
  {
    uint8_t byte; ds>>byte;
    pack.flags[7] = (byte & 0x80) /0x80; //org = from 0 to 7
    pack.flags[6] = (byte & 0x40) /0x40;
    pack.flags[5] = (byte & 0x20) /0x20;
    pack.flags[4] = (byte & 0x10) /0x10;
    pack.flags[3] = (byte & 0x08) /0x08;
    pack.flags[2] = (byte & 0x04) /0x04;
    pack.flags[1] = (byte & 0x02) /0x02;
    pack.flags[0] = byte & 0x01;
  }
  return ds;  
}

PoolByteArrayStream &operator>>( PoolByteArrayStream &ds, _SFFV2_LZ5_RLE_PACKET &pack ) 
{
  {
    uint8_t byte1, byte2; ds>>byte1;
    pack.numtimes = (int) ( (byte1 & 0xe0) >> 5);
    if(pack.numtimes == 0) {
    ds>>byte2; 
    pack.numtimes = (int) byte2; pack.numtimes = pack.numtimes + 8;
    }
    pack.color = byte1 & 0x1f;
  }  
  return ds;
}

PoolByteArrayStream &operator>>( PoolByteArrayStream &ds, _SFFV2_LZ5_LZ_PACKET &pack )
{
  { 
  uint8_t byte1, byte2, byte3; ds>>byte1;
  pack.len = (int) (byte1 & 0x3f);
  if(pack.len == 0) {
    //long lz packet
    ds>>byte2; ds>>byte3;
    pack.offset = (int) (byte1 & 0xc0);
    pack.offset = pack.offset * 4;
    pack.offset = pack.offset + ( (int) byte2 );
    pack.offset++;
    pack.len = (int) byte3;
    pack.len = pack.len + 3;      
    }
    else {
    //short lz packet   
    pack.len++;
    uint8_t tmp_recyc = byte1 & 0xc0;
      if(pack.recycled_bits_filled==2) tmp_recyc = tmp_recyc >>2;
      if(pack.recycled_bits_filled==4) tmp_recyc = tmp_recyc >>4;
      if(pack.recycled_bits_filled==6) tmp_recyc = tmp_recyc >>6;
      pack.recycled = pack.recycled + tmp_recyc;
      pack.recycled_bits_filled = pack.recycled_bits_filled +2;
      if(pack.recycled_bits_filled < 8) {
      ds>>byte2; pack.offset = (int) byte2;    
      }
      if(pack.recycled_bits_filled == 8) {
      pack.offset = (int) pack.recycled;
      pack.reset();    
      }
      pack.offset++;      
    }
  }
  return ds;
}

PoolColorArray _sffv2_makeColorArray (PoolByteArray &src, int dim) {
  PoolColorArray palette;
  PoolByteArrayStream in(src);

  std::string message = "Build palette with size " + std::to_string(dim);
  Godot::print(message.c_str());

  uint8_t r, g, b, skip;
  for(int a = 0; a < dim; a++) {
    in>>r; in>>g; in>>b; in>>skip;
    palette.append( Color(
      ((float) r / 255.0),
      ((float) g / 255.0),
      ((float) b / 255.0),
      a == 0 ? 0 : 1
    ) );
  }
  return palette;
}

Image *_sffv2_makeImage (PoolByteArray &src, int w, int h, PoolColorArray &colors) {
  PoolByteArray dest;

  std::string message;
  message = "Array size is " + std::to_string(src.size());
  Godot::print(message.c_str());
  message = "Palette size is " + std::to_string(colors.size());
  Godot::print(message.c_str());

  for (int i=0; i<(w * h);i++) {
    Color color = colors[src[i]];
    dest.append(color.r);
    dest.append(color.g);
    dest.append(color.b);
    dest.append(color.a);
  }

  Image *img = Image::_new();
  img->create_from_data(w, h, false, Image::Format::FORMAT_RGBA8, dest);

  return img;
}

void _sffv2_rle8Decode(PoolByteArray &src)
{
  std::string message;
  message = "Decoding source with bytes: " + std::to_string(src.size());
  Godot::print(message.c_str());

  PoolByteArrayStream in(src);
  PoolByteArray dest;
  uint8_t ch, color;
  {uint32_t i; in>>i; }
  while(!in.atEnd()) {
    in>>ch;
    if((ch & 0xc0) == 0x40) {
    in>>color;
    for(uint8_t a=0; a< ((ch & 0x3f)); a++) { dest.append(color); }  
    }
    if((ch & 0xc0) != 0x40) { dest.append(ch); }
  }

  message = "Result have bytes: " + std::to_string(dest.size());
  Godot::print(message.c_str());

  src = dest;  
}

void _sffv2_rle5Decode(PoolByteArray &src) { 
  PoolByteArray dest;
  {
    PoolByteArrayStream in(src);
    uint8_t color=0;
    {uint32_t tmp; in>>tmp; }
    while(!in.atEnd()) {
      _SFFV2_RLE5_PACKET rle5; in>>rle5;
      if(rle5.color_bit == 1) in>>color;
      if(rle5.color_bit == 0) color=0;
      for(uint8_t run_count=0; run_count <= rle5.run_len; run_count++) dest.append((int8_t) color);
      for(uint8_t bytes_processed=0; bytes_processed < rle5.data_len; bytes_processed++) {
        uint8_t one_byte; in>>one_byte;
        color = one_byte & 0x1f;
        uint8_t run_len = one_byte >> 5;
        for(uint8_t run_count = 0; run_count <= run_len; run_count++) dest.append((int8_t) color);    
        }
    }
  }
  src = dest;
}

PoolByteArray subarray(PoolByteArray source, int start, int end) {
  PoolByteArray dest;
  dest.resize(end - start);
  for (int i=start; i<=end; i++) {
    dest.append(source[i]);
  }
  return dest;
}

void _sffv2_lz5Decode(PoolByteArray &src) {
  PoolByteArray dest;
  PoolByteArrayStream in(src);
  _SFFV2_LZ5_CONTROL_PACKET ctrl;
  _SFFV2_LZ5_RLE_PACKET rle;
  _SFFV2_LZ5_LZ_PACKET lz;lz.reset();
  { uint32_t tmp; in>>tmp; }
  while(!in.atEnd()) {
    in>>ctrl; //control packet
    for(int a=0; a<8; a++) { //lettura degli 8 packet successivi
    if(in.atEnd()) break;
    if(ctrl.flags[a] == 0) {
      //rle packet
      in>>rle;for(int b=0; b<rle.numtimes; b++) dest.append((int8_t) rle.color);  
      }
      if(ctrl.flags[a] == 1) {
      //lz packet 
      in>>lz;
      PoolByteArray tmpArr = dest;
      int tmpArrSize = tmpArr.size();
      int startIndex = tmpArrSize - lz.offset;
      int endIndex = std::min(startIndex + lz.len, tmpArrSize - 1);
      tmpArr = subarray(tmpArr, startIndex, endIndex);
    while(tmpArr.size() < lz.len) {
      tmpArr.append_array(tmpArr);
        }
    if (tmpArr.size() > lz.len) {
      tmpArr = subarray(tmpArr, 0, lz.len - 1);
    }
    dest.append_array(tmpArr);
      }
    } 
  }
  src = dest;
}
