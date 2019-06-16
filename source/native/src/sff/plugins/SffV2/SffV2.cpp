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

#include "../../SffHandler.h"
#include "../../SffItem.h"
#include "../../data/ByteArray.hpp"
#include "../../data/ByteArrayStream.hpp"
#include "../../data/FileStream.hpp"
#include <Image.hpp>
#include "SffV2.h"
#include "internal_sffv2_structs.h"
#include "internal_sffv2_rle5-lz5_decode.h"
#include "internal_sffv2_rle8.h"
#include "internal_sffv2_matrix-image.h"
#include "internal_sffv2_matrix-pal.h"
#include "internal_sffv2_lz5_encode.h"
#include "internal_sffv2_wText_calc.h"

bool SffV2::read(String filename)
{
    _SFFV2_SFF_HEADER head;
    vector<_SFFV2_SPRITE_NODE_HEADER> sprnode;
    vector<_SFFV2_PAL_NODE_HEADER> palnode;

    File* sffFile = File::_new();
    Error error = file->open(filename, File::ModeFlags::READ);

    if (error != Error::OK) {
        Godot::print("Error opening sff file");
        false;
    }

    DataStream in(&sffFile);
    in >> head;
    if (strcmp(&head.signature[0], "ElecbyteSpr") != 0)
        return false;
    if (head.verhi != 2)
        return false;

    //reading palnodes
    in->seek((uint64_t)head.first_palnode_offset);
    for (long a = 0; a < head.total_palettes; a++) {
        _SFFV2_PAL_NODE_HEADER tmp_palnode;
        in >> tmp_palnode;
        palnode.append(tmp_palnode);
    }
    //reading sprnodes
    in->seek((uint64_t)head.first_sprnode_offset);
    for (long a = 0; a < head.total_frames; a++) {
        _SFFV2_SPRITE_NODE_HEADER tmp_sprnode;
        in >> tmp_sprnode;
        sprnode.append(tmp_sprnode);
    }

    //reading pals
    for (int a = 0; a < palnode.size(); a++) {
        SffPal sffpal;
        sffpal.groupno = (int)palnode[a].groupno;
        sffpal.itemno = (int)palnode[a].itemno;
        if (palnode[a].len == 0) { //linked pal
            sffpal.pal.clear();
            sffpal.pal += paldata[palnode[a].linked].pal;
        }
        if (palnode[a].len > 0) { //"normal" pal
            sffpal.pal.clear();
            uint64_t offset = (uint64_t)head.ldata_offset;
            offset += (quint64)palnode[a].offset;
            in->seek(offset);

            int k = (int)palnode[a].numcols;
            k = k * 4;
            char* tmpStr = new char[k];
            in.readRawData(tmpStr, k);
            ByteArray tmpArr;
            tmpArr.append(tmpStr, k);
            k = k / 4;
            sffpal.pal += _sffv2_matrixToPal(tmpArr, k);
            delete[] tmpStr;
            tmpArr.clear();
        }
        paldata.append(sffpal);
    }

    //reading images
    for (int a = 0; a < sprnode.size(); a++) {
        SffData sffitem;
        sffitem.groupno = (int)sprnode[a].groupno;
        sffitem.imageno = (int)sprnode[a].imageno;
        sffitem.x = (int)sprnode[a].x;
        sffitem.y = (int)sprnode[a].y;
        sffitem.palindex = (int)sprnode[a].palindex;
        if (sprnode[a].len == 0) { //linked image
            sffitem.linked = -1;
            sffitem.image = sffdata[sprnode[a].linked].image;
        }
        if (sprnode[a].len != 0) { //"normal" image
            uint64_t offset = 0;
            if (sprnode[a].flags == 0)
                offset = (uint64_t)head.ldata_offset;
            if (sprnode[a].flags != 0)
                offset = (uint64_t)head.tdata_offset;
            offset += (uint64_t)sprnode[a].offset;
            in->seek(offset);

            Image* img;
            char* tmpStr = new char[sprnode[a].len];
            ByteArray tmpArr;
            in.readRawData(tmpStr, ((int)sprnode[a].len));
            tmpArr.append(tmpStr, ((int)sprnode[a].len));

            //decoding encoded data
            if (sprnode[a].fmt == 2)
                _sffv2_rle8Decode(tmpArr);
            if (sprnode[a].fmt == 3)
                _sffv2_rle5Decode(tmpArr);
            if (sprnode[a].fmt == 4)
                _sffv2_lz5Decode(tmpArr);

            //adding image
            if (sprnode[a].colordepth == 5 || sprnode[a].colordepth == 8) {
                img = _sffv2_matrixToImage8(tmpArr, ((int)sprnode[a].w),
                    ((int)sprnode[a].h), paldata[sffitem.palindex].pal);
            }
            //altri casi da aggiungere (immagini a colori reali 16,24 e 32) qui
            //al momento non vengono aggiunti perché non supportati

            sffitem.image = img;
            sffitem.linked = -1;
            delete[] tmpStr;
            tmpArr.clear();
        }
        sffdata.append(sffitem);
    }

    //last step: matching for paldata isUsed and usedby
    for (int a = 0; a < sffdata.size(); a++) {
        int b = sffdata[a].palindex;
        if (paldata[b].isUsed == false) {
            paldata[b].isUsed = true;
            paldata[b].usedby = a;
        }
    }

    return true;
}
