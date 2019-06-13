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

#ifndef SFF__H
#define SFF__H

#include <Godot.hpp>
#include <vector>
#include "SffStructs.h"

using namespace std;

/*
class Sff loads and save sff files throughout "sff plugins"
Sff stores data in "data".

Data can be used in this way:
you can obtain the pointer of a single SffItem inside "data" using function "searchItem"
*/

//! This is the class that manages Sff data (palettes and images)
class Sff {

public: //constructors - destructors
  Sff();
  ~Sff();

public: //datas
  //! paldata is a list that contains pal infos
  vector<SffPal> paldata;
  //! sffdata is a list that contains sprite infos
  vector<SffData> sffdata;
  //! this bool marks if "sff" is saved or not. It is public so be careful
  bool isSaved;
  //! this is the original filename where you loaded Sff
  String filename;
  //! An int value that returns the ID of actual Image (usefull for "Extract Actual Image")
  int actualImage;
  //! This is a value (from 1 to PLUGIN_NUMBER) that indicates the actual Sff Format for saving
  /*!
     see Sff::saveSff
  */
  char format;
  //! if true it will say to PLUGIN->write to remove duplicate images
  bool removeDuplicates;

public: //relevant return values
  //! It will return a pointer of a single sprite data (useful for SffItem)
  SffData * item(int itemID); //groupno, imageno
  //! It will return an int value corresponding to the ID of the first image with that groupno, imageno (if no errors, there should be only one image with that infos)
  int searchItem(int groupno, int imageno); //itemID
  //! It will return an int value corresponding to the ID of the first image with that groupno
  int searchItem(int groupno); //itemID
  //! It will return a list of PAL.groupno used in paldata. Useful for Palette Section
  vector<int> usedPalGroups(); //list of groups used in palette

public: //resync and clear
  //! This function is used internally by Palette Section when you remove an image
  /*!
      This function, in particular, will recheck the palette info for every image (becouse, after removing an image, the infos can be wrong so this function will fix all image infos about palette)
      @param index the index of the image removed
  */
  void resyncPaletteAfterRemoveItem(int index);
  //! clear all Sff internal datas
  void clear();

public: //load - save
  //! load an Sff.
  /*!
      This function delegates the work to a function that checks for all SFF_PLUGINS
      until it finds a plugin read functions that returns true.
      When it finds the right plugin reader, it takes sffdata and paldata from that plugin.
      @param filename the name of sff to load
      \sa class SffHandler and \ref pageSffPluginSystem
  */
  bool loadSff(String & _filename);
   //! Save an Sff.
  /*!
      This function delegates the work to a function that uses the plugin selected
      After selecting the SFF_PLUGIN writer, it writes sff using that plugin.
      @param filename the name that sff file will have after saving
      @param sff_type It is a number that marks what plugin you use for saving
      \sa class SffHandler and \ref pageSffPluginSystem
  */
  bool saveSff(String & _filename, char sff_type = 1);

};

#endif

