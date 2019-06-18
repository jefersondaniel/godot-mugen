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

//matrix-pal.  Convert a ByteArray "raw" to a vector <Rgb>.

//pal-matrix.  Reverse conversion



ByteArray _sffv2_matrixToPal (ByteArray &src, int dim) {
  ByteArray palette;
  ByteArrayStream in(src);
  uint32_t r, g, b, skip;
  for(int a = 0; a < dim; a++) {
    in>>r; in>>g; in>>b; in>>skip;
    palette.append(r);
    palette.append(g);
    palette.append(b);
    palette.append(a == 0 ? 0 : 255);
  }
  return palette;
}
