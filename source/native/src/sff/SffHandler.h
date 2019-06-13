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

#ifndef SFF_HANDLER_H
#define SFF_HANDLER_H

#include <Godot.hpp>
#include "SffItem.h"
#include <vector>

using namespace std;

/*
class SffHandler is the pure virtual class to subclass for reading sff
files throughout "sff plugins".

Every "sff plugin" is a subclass of SffHandler.

For details about select_sff_plugin_reader and select_sff_plugin_writer
see "SffHandler.cpp" for more details about them
*/
//! Class that defines an Sff_Plugin
/*!
   \sa \ref pageSffPluginSystem
   \sa \ref pageNomenPolicies
*/
class SffHandler {
  public:
    SffHandler();
    //! sprite list to load with PLUGIN or to save from SFF
    vector<SffData> sffdata;
    //! pal list to load with PLUGIN or to save from SFF
    vector<SffPal> paldata;
    //! used by PLUGIN::write to mark if linking images or not during Sff saving process
    bool removeDuplicates;

  public:
    //! pure virtual function. Must be reimplemented in your own SffPlugin
    /*!
       \sa \ref pageSffPluginSystem

    */
    virtual bool read(String & filename) = 0;

  public:
    //! returns how many different groupno used in sff (useful only for sffv1 at the moment)
    const int sffGroupCount();
    vector<int> usedPalGroups();
    //! Checks for duplicate images. Actually used only by sffv2 (sffv1 has a different internal function for the same work)
    void searchDuplicateImages();
    //! Check Sff for errors (for example if two or more images with same groupno, imageno)
    /*!
       @param rgbSupported set to true only if your Sff format supports Rbg Images. If your Sff format doesn't support Rgb Images set it to false.
       \return a string value corresponding to error message. Empty if no errors.
    */
    string scanSff(bool rgbSupported);
};

//! Selects the SffPlugin reader to Use
/*! \relates Sff
   This function is used internally by Sff::read()
   \return a pointer to the plugin selected
   \sa \ref pageSffPluginSystem
*/
SffHandler * select_sff_plugin_reader(String &filename);

//! Selects the SffPlugin writer to Use
/*! \relates Sff
    This function is used internally by Sff::write()
   \return a pointer to the plugin selected
   \sa \ref pageSffPluginSystem
*/
SffHandler * select_sff_plugin_writer(String &filename, char sff_type = 1);

#endif
