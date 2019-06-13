#ifndef SFF_STRUCTS_H
#define SFF_STRUCTS_H

#include <Godot.hpp>
#include <Image.hpp>

//! Structure that contains the info for a single palette
struct SffPal {
  //! palette data
  ByteArray pal;
  //! pal itemno
  int itemno;
  //! pal groupno
  int groupno;
  //! indicates if the palette is used at least by a sprite
  bool isUsed;
  //! indicates what image use this pal (-1 if unused)
  int usedby; //ID of first SffData item that uses that image
  //! A special parameter for Nomen internal usage only. When unused it is always == -1
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
  //! Image Drawing
  Image *image;
  //! image groupno
  int groupno;
  //! image imageno
  int imageno;
  //! image offset x
  int x;
  //! image offset y
  int y;
  //! The index value of palette used by sprite
  int palindex;
  /*!
     This parameter is used in a particular way. Inside Sff is always == -1.
     When SffHandler receives the sffdata(s) all "linked" values will be == -1.
     If removeDuplicates is enabled you need to use palindex as an extra parameter that contains the sprite linked to (if matches any) else it will remain -1
  */
  int linked;
};

#endif
