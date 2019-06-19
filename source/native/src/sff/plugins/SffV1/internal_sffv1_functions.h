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

// SFFv1 INTERNAL ONLY. DON'T USE THIS HEADER OUTSIDE sffv2

//matrix-pal.  Convert a ByteArray "raw" to a vector <QRgb>.

Palette _sffv1_matrixToPal (ByteArray &src) {
  Palette palette;
  ByteArrayStream in(src);
  uint8_t r, g, b;
  for(int a = 0; a < 256; a++) {
    in>>r; in>>g; in>>b;
    palette.colors.push_back(RawColor(r, g, b, a == 0 ? 0 : 255));
  }
  return palette;
}
