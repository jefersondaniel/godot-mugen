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

#ifndef NOMEN_SFF_FUNCTIONS_H
#define NOMEN_SFF_FUNCTIONS_H

#include <Godot.hpp>

//! returns true if pal1 == pal2. Else returns false
bool nomenComparePalettes(ByteArray &pal1, ByteArray &pal2);
//! if palette "param" is 32-colors, it returns a 256-color palette equal to "param" (all colors from 32 to 255 will be 0,255,0)
ByteArray nomenPalFiller(ByteArray &param);

//! load a palette from JASC PAL and returns palette
ByteArray nomenLoadPal_pal(QString & filename);
//! load a palette from Photoshop Act and returns palette
ByteArray nomenLoadPal_act(QString & filename);

#endif

