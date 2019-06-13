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

enum _SFFV2_LZ5_NOMEN_PACKER__NAME {
  rle, short_lz, long_lz
};


struct _SFFV2_LZ5_NOMEN_PACKER {
  _SFFV2_LZ5_NOMEN_PACKER__NAME type;
  int value1; int value2;
  //LZ5_RLE packet:  value1 = color,  value2 = numtimes
  //LZ5_LZ  packet:  value1 = len  ,  value2 = offset
};


// while we have an unique _SFFV2_LZ5_LZ_PACKET for reading, we have 2 indipendent LZ5_LZ_PACKET writers:
// _SFFV2_LZ5_LZ_LONG_PACKET for long lz packets and _SFFV2_LZ5_LZ_SHORT_PACKET for short lz packets


struct _SFFV2_LZ5_LZ_LONG_PACKET {
  int len;
  int offset;
};


struct _SFFV2_LZ5_LZ_SHORT_PACKET {
  int len;
  int offset;
  unsigned char recycled;
  unsigned char recycled_bits;
};




DataStream &operator<<( DataStream &ds, const _SFFV2_LZ5_CONTROL_PACKET &pack )
{
  {
    unsigned char byte = 0;
    byte += pack.flags[7] * 0x80;
    byte += pack.flags[6] * 0x40;
    byte += pack.flags[5] * 0x20;
    byte += pack.flags[4] * 0x10;
    byte += pack.flags[3] * 0x08;
    byte += pack.flags[2] * 0x04;
    byte += pack.flags[1] * 0x02;
    byte += pack.flags[0] * 0x01;
    ds<<byte;
  }
  return ds;
}


DataStream &operator<<( DataStream &ds, _SFFV2_LZ5_RLE_PACKET &pack )
{
  if(pack.numtimes <= 7) {
	  //short lz_rle packet
	  unsigned char ch = (unsigned char) pack.numtimes;
	  ch = ch << 5;
	  ch += (unsigned char) pack.color;
	  ds<<ch;
  }
  if(pack.numtimes >= 8) {
	  //long lz_rle packet
	  pack.numtimes -= 8;
	  unsigned char ch1 = (unsigned char) pack.color;
	  unsigned char ch2 = (unsigned char) pack.numtimes;
	  ds<<ch1; ds<<ch2;
  }
  return ds;
}


DataStream &operator<<( DataStream &ds, const _SFFV2_LZ5_LZ_LONG_PACKET &pack )
{
  int temp = pack.offset / 256; //prende solo i 2 bits superiori. Valori possibili: 0-3
  unsigned char ch1 = (unsigned char) temp;
  ch1 = ch1 << 6;

  temp = pack.offset - ((pack.offset / 256) * 256); //pack.offset / 256 prende i 2 bit superiori. Rimoltiplicando si perdono i bit inferiori. Con la differenza si riottengono solo i bit inferiori
  unsigned char ch2 = (unsigned char) temp;

  unsigned char ch3 = (unsigned char) pack.len;

  ds<<ch1; ds<<ch2; ds<<ch3;

  return ds;
}


DataStream &operator<<( DataStream &ds, const _SFFV2_LZ5_LZ_SHORT_PACKET &pack )
{
  unsigned char ch = (unsigned char) pack.len;
  ch += pack.recycled;
  ds << ch;
  if(pack.offset != -5) {
    ch = (unsigned char) pack.offset;
    ds << ch;
  }
  return ds;
}
