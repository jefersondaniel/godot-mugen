#ifndef SFF_STRUCTS_H
#define SFF_STRUCTS_H

#include <Godot.hpp>
#include <Image.hpp>
#include "data/ByteArray.hpp"
#include "image/RawImage.hpp"

//! Structure that contains the info for a single palette
struct SffPal {
  Palette pal;
  int itemno;
  int groupno;
  bool isUsed;
  int usedby; //ID of first SffData item that uses that image
  int reserved; //"reserved" is used internally only. It is a parameter for working under Palette Section
  SffPal() {
    itemno = -1; groupno = -1;
    isUsed = false;
    usedby = -1; reserved = -1;
  }
  // bool isTrueColor; //for true colors image
};

//! Structure that contains the info for a single sprite
struct SffData {
  RawImage image;
  int groupno;
  int imageno;
  int x;
  int y;
  int palindex;
  int linked;
};

#endif
