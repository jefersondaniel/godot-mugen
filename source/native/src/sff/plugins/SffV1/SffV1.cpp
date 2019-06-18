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
#include "../../data/ByteArray.hpp"
#include "../../data/ByteArrayStream.hpp"
#include "../../data/FileStream.hpp"
#include "../../image/PCXReader.hpp"
#include <Image.hpp>
#include <File.hpp>
#include "SffV1.h"
#include "../../nomenSffFunctions.h"
#include "internal_sffv1_structs.h"
#include "internal_sffv1_functions.h"

#include <string>

bool SffV1::read(String filename)
{
    _SFFV1_SFF_HEADER head;
    _SFFV1_SFF_SPRITE_HEADER spr;

    File* sffFile = File::_new();
    Error error = sffFile->open(filename, File::ModeFlags::READ);

    if (error != Error::OK) {
        Godot::print("Error opening sff file");
        false;
    }

    FileStream in(sffFile);

    in >> head;
    if (strcmp(&head.signature[0], "ElecbyteSpr") != 0) {
        Godot::print("SffV1::read invalid signature");
        return false;
    }
    if (head.verhi != 0 && head.verlo != 1 && head.verlo2 != 0 && head.verlo3 != 1) {
        Godot::print("SffV1::read invalid version");
        return false;
    }

    Godot::print("SffV1::read start");

    long actual_offset = head.first_offset;
    //bool first_sprite = true;
    ByteArray palref;
    int counter = -1;
    int actual_palindex = 0;
    vector<int> sharedImage; //used only in charecter sff decoding
    vector<int> indImage; //indivudual images list - used only in character sff decoding

    while (!in.atEnd()) {
        SffData sffitem;
        counter++;
        in >> spr;
        long arraySize = spr.offsetNextSprite - actual_offset - 32;
        if (arraySize > 0) { //normal image
            ByteArray tmpArr;
            in.readRawData(tmpArr, ((int)arraySize));

            if (head.isShared == true && spr.isShared == true) {
                sharedImage.push_back(counter); //add current image index to "sharedImages" list if it is a shared image and if it is a char-sff
                for (int a = 0; a < 768; a++) {
                    uint8_t ch = 0;
                    tmpArr.append(ch);
                }
            }

            if (head.isShared == false && spr.isShared == true) { //if the sff is a non-char one (and image is shared), mantain original reading approach like v. 0.1
                tmpArr.append(palref); //if sff is non-char sff append palref and NOT use sharedImages list
            }

            if (spr.isShared == false) {
                indImage.push_back(counter);
                actual_palindex = paldata.size(); //actual pal index for this sff item. Starts as a new value to take if uses a new pal. Will change if the pal used is not new
                palref = tmpArr;
                palref = palref.right(768);
                tmpArr.append(palref);
                SffPal sffpal;
                sffpal.pal = _sffv1_matrixToPal(palref);
                sffpal.groupno = paldata.size() + 1;
                sffpal.itemno = 1;
                sffpal.isUsed = true;
                sffpal.usedby = counter;
                { //check if this pal is already present and if new add it to paldata
                    bool checked = false;
                    for (int k = 0; k < paldata.size(); k++) {
                        if (sffpal.pal == paldata[k].pal) {
                            checked = true;
                            actual_palindex = k;
                            break;
                        }
                    }
                    if (checked == false) {
                        paldata.push_back(sffpal); //append only if paldata is new
                    }
                }
            }
            //assigning palindex to sffimage
            sffitem.palindex = actual_palindex;
            //setting image:
            {
                PCXReader reader(tmpArr);
                bool success = reader.read(&sffitem.image);
                if (!success) {
                    cerr << "error reading pcx image" << endl;
                }
            }
            tmpArr.clear();
        }

        else { //linked image
            sffitem.image = sffdata[spr.linked].image;
            sffitem.palindex = sffdata[spr.linked].palindex;
            if (head.isShared == true && spr.isShared == true)
                sharedImage.push_back(counter);
        }

        sffitem.groupno = (int)spr.groupno;
        sffitem.imageno = (int)spr.imageno;
        sffitem.x = (int)spr.x;
        sffitem.y = (int)spr.y;
        sffitem.linked = -1;
        if (head.isShared == true && spr.isShared == true)
            sffitem.palindex = 0;

        sffdata.push_back(sffitem);
        actual_offset = spr.offsetNextSprite;

        /*{
      QFile outdebugfile("debug.txt");
      outdebugfile.open(QIODevice::Append | QIODevice::Text);
      QTextStream outdebug(&outdebugfile);
      outdebug<<"Image: "<<sffitem.groupno<<", "<<sffitem.imageno<<"\n";
      outdebug<<"Shared Attributes -> SharedSff = ";
      if(head.isShared==true) outdebug<<"Yes";
      if(head.isShared==false) outdebug<<"No";
      outdebug<<";  SharedImage = ";
      if(spr.isShared==true) outdebug<<"Yes\n";
      if(spr.isShared==false) outdebug<<"No\n";
      outdebug<<"------------------------\n\n";
      outdebugfile.close();
    }*/
    }

    //final step... reapply palette for char-sff shared images - needed in order to avoid possible problems
    if (head.isShared) {
        Palette forcePal;
        //setting forcepal
        bool have0 = false; //have0 = checking if there is a 0,x individual image
        //verify if there is a 0,x individual
        for (int k = 0; k < indImage.size(); k++) {
            if (sffdata[indImage[k]].groupno == 0) {
                have0 = true;
                forcePal = sffdata[indImage[k]].image.colorTable();
                break;
            }
        }
        //if there isn't a 0,x individual check other
        if (have0 == false) {
            bool have90; // have90 = check 9000,0
            for (int k = 0; k < indImage.size(); k++) {
                int alfa = indImage[k];
                if (sffdata[alfa].groupno == 9000 && sffdata[alfa].imageno == 0) {
                    have90 = true;
                    forcePal = sffdata[indImage[k]].image.colorTable();
                    break;
                }
            }
            if (have90 == false) { //if no 0,x neither 9000,0 individual image (nearly impossible) than check for first non-9000,1 individual image
                forcePal = sffdata[indImage[0]].image.colorTable(); //default value in case only one color
                /*if(indImage.size() >=2) {
            if(sffdata[0].groupno == 9000 && sffdata[0].imageno == 1) {
              forcePal = sffdata[indImage[1]].image.colorTable();
            }
          } */
            }
        }

        //now forcePal is assigned. A)Swap Palettes if forcepal != (palindex = 0 / 1,1)
        {
            int k = 0;
            for (k = 0; k < paldata.size(); k++) {
                if (forcePal == paldata[k].pal)
                    break;
            }

            if (k > 0) { //forcePal is not palindex = 0 than not 1,1. Swap forcePal with the current palindex = 0
                for (int w = 0; w < sffdata.size(); w++) {
                    //update palindex to the image that were linked to the palindex = 0 or palindex = k and swap them
                    if (sffdata[w].palindex == 0)
                        sffdata[w].palindex = k;
                    else if (sffdata[w].palindex == k)
                        sffdata[w].palindex = 0;
                }
                paldata[0].groupno = paldata[k].groupno;
                paldata[0].itemno = paldata[k].itemno;
                paldata[k].groupno = 1;
                paldata[k].itemno = 1;

                SffPal aux = paldata[0];
                paldata[0] = paldata[k];
                paldata[k] = aux;
            }
        }

        //B) Reassigning images palettes to shared images
        for (int k = 0; k < sharedImage.size(); k++) {
            sffdata[sharedImage[k]].image.setColorTable(forcePal);
            sffdata[sharedImage[k]].palindex = 0;
        }
    }

    sffFile->close();

    return true;
}
