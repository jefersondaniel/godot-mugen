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

/*******************************************************
 *  RLE5
 ******************************************************/

struct _SFFV2_RLE5_PACKET {
  unsigned char run_len;
  unsigned char color_bit;
  unsigned char data_len;
};


ByteArrayStream &operator>>( ByteArrayStream &ds, _SFFV2_RLE5_PACKET &rle5 )
{
  ds >> rle5.run_len;
  {
    unsigned char byte_process;
    ds >> byte_process;
	rle5.color_bit = (byte_process & 0x80) /0x80; //1 if bit7 = 1; 0 if bit7 = 0
	rle5.data_len = byte_process & 0x7f; //value of bits 0-6
  }
  return ds;
}


void _sffv2_rle5Decode(ByteArray &src) {
  ByteArray dest;
  {
    ByteArrayStream in(src);
    unsigned char color=0;
    {uint32_t tmp; in>>tmp; } //skip first 4 bytes - they specify the size of uncompressed data (useless)
    while(!in.atEnd()) {
	  _SFFV2_RLE5_PACKET rle5; in>>rle5;
	  if(rle5.color_bit == 1) in >> color;
	  if(rle5.color_bit == 0) color=0;
	  for(unsigned char run_count=0; run_count <= rle5.run_len; run_count++) dest.append((char) color);
	  for(unsigned char bytes_processed=0; bytes_processed < rle5.data_len; bytes_processed++) {
	    unsigned char one_byte; in >> one_byte;
	    color = one_byte & 0x1f;
	    unsigned char run_len = one_byte >> 5;
	    for(unsigned char run_count = 0; run_count <= run_len; run_count++) dest.append((char) color);
      }
    }
  }
  src = dest;
}




/*******************************************************
 *  LZ5
 ******************************************************/


struct _SFFV2_LZ5_CONTROL_PACKET {
  unsigned char flags[8];
};


struct _SFFV2_LZ5_RLE_PACKET {
  uint8_t color;
  int numtimes;
};


struct _SFFV2_LZ5_LZ_PACKET {
  int len;
  int offset;
  unsigned char recycled;
  unsigned char recycled_bits_filled;
  void reset() {
    recycled = 0;
    recycled_bits_filled = 0;
  }
};


ByteArrayStream &operator>>( ByteArrayStream &ds, _SFFV2_LZ5_CONTROL_PACKET &pack )
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


ByteArrayStream &operator>>( ByteArrayStream &ds, _SFFV2_LZ5_RLE_PACKET &pack )
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


ByteArrayStream &operator>>( ByteArrayStream &ds, _SFFV2_LZ5_LZ_PACKET &pack )
{
  //tenere in considerazione eventualità di cui sopra
  {
	uint8_t byte1, byte2, byte3; ds>>byte1;
	pack.len = (int) (byte1 & 0x3f);
	if(pack.len == 0) {
	  //long lz packet
	  ds>>byte2; ds>>byte3;
	  pack.offset = (int) (byte1 & 0xc0);
	  pack.offset = pack.offset * 4; // <<2 seem that doesn't work in int. So applied *4 that have the same effect
	  pack.offset = pack.offset + ( (int) byte2 );
	  pack.offset++;
	  pack.len = (int) byte3;
	  pack.len = pack.len + 3;
    }
    else {
	  //short lz packet
	  pack.len++;
	  uint8_t tmp_recyc = byte1 & 0xc0;
	  //if(pack.recycled_bits_filled==0) do nothing
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




void _sffv2_lz5Decode(ByteArray &src) {
  ByteArray dest;
  ByteArrayStream in(src);
  _SFFV2_LZ5_CONTROL_PACKET ctrl;
  _SFFV2_LZ5_RLE_PACKET rle;
  _SFFV2_LZ5_LZ_PACKET lz;lz.reset();
  {uint32_t tmp; in>>tmp; } //skip first 4 bytes - they specify the size of uncompressed data (useless)
  while(!in.atEnd()) {
	in>>ctrl; //control packet
    for(int a=0; a<8; a++) { //lettura degli 8 packet successivi
	  if(in.atEnd()) break;
	  if(ctrl.flags[a] == 0) {
	    //rle packet
	    in>>rle;for(int b=0; b<rle.numtimes; b++) dest.append((char) rle.color);
      }
      if(ctrl.flags[a] == 1) {
	    //lz packet
	    in>>lz;
	    ByteArray tmpArr = dest; tmpArr = tmpArr.right(lz.offset);
		tmpArr.truncate(lz.len);
		while(tmpArr.size() < lz.len) {
		  /*
		     this case is undocumented by Elecbyte. I discovered it during debugging:
		        if the len > offset than the the copy must restart from the "beginning" of offset
		        example:
		        if you have lz.len == 10 and lz.offset == 7 than
		          - you must find the last 7 bytes decoded (as usual)

		          01 02 03 04 05 06 07

		          - then you will have the array " 01 02 03 04 05 06 07 "


		          - but the final bytes to append should be

		          01 02 03 04 05 06 07 01 02 03 //reached 10 bytes

		          becouse you need that the final array len==10

		          - so you need to add to the array again the string until you reach
		            the size of 10
		  */
		  tmpArr.append(tmpArr); tmpArr.truncate(lz.len);
        }
		dest.append(tmpArr);
      }
    }
  }
  src = dest;
}

