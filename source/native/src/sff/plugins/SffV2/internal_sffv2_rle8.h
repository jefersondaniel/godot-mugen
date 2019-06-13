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

//rle8 in sffv2 is different than normal rle8. Infact we must use an
// if((ch & 0xc0) == 0x40) instead of an if((ch & 0xc0) == 0xc0)

void _sffv2_rle8Decode( ByteArray &src )
{
  DataStream in(src);
  ByteArray dest;
  unsigned char ch, color;
  {uint32_t i; in>>i; } //undocumented: first 4 bytes = len of image

  while(!in.atEnd()) {
    in>>ch;
    if((ch & 0xc0) == 0x40) { //=0x40
	  in>>color;
	  for(unsigned char a=0; a< ((ch & 0x3f)); a++) { dest.append(color); }
    }
    if((ch & 0xc0) != 0x40) { dest.append(ch); }
  }
  src = dest;
}
