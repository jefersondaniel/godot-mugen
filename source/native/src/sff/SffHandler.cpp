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


#include "SffHandler.h"
#include "SffPlugins__headers.h"
#include <Godot.hpp>

using namespace std;

/*
  Here stands the definition for select_sff_plugin_reader and select_sff_plugin_writer
  Those two functions interacts with plugins throughout "SffPlungins__headers.h" and
  "SffPluginsList.h"

  In "SffPlugins__headers.h" you must add the main header for every single "sff plugin"
  In "SffPluginsList.h" you must add a macro ADD_SFF_PLUGIN(class) for every single "sff plugin"
*/

SffHandler * select_sff_plugin_reader(String filename) {
  #ifdef ADD_SFF_PLUGIN
  #undef ADD_SFF_PLUGIN
  #endif

  #define ADD_SFF_PLUGIN(SFF_PLUGIN_CLASS, SFF_PLUGIN_DESCRIPTION) \
    { SFF_PLUGIN_CLASS * pointer = new SFF_PLUGIN_CLASS; \
      if(pointer->read(filename) == true) return pointer; \
      else delete pointer; }

  #include "SffPluginsList.h"
  #undef ADD_SFF_PLUGIN

      return NULL;
}

SffHandler::SffHandler() {
   this->removeDuplicates = true;
}

const int SffHandler::sffGroupCount() {
    vector <int> values;
    for(int a=0; a<sffdata.size(); a++) {
        bool new_value=true;
        for(int b=0; b<values.size(); b++) {
            if(sffdata[a].groupno == values[b]) { new_value=false; break; }
        }
        if(new_value==true) { values.push_back(sffdata[a].groupno); }
    }
    return values.size();
}

void SffHandler::searchDuplicateImages() {
    for (int a = 0; a < sffdata.size(); a++) {
        for (int b = a+1; b < sffdata.size(); b++) {
            if(sffdata[a].image == sffdata[b].image && sffdata[a].linked == -1) sffdata[b].linked = a;
            //&& sffdata[a].linked == -1 -> if false it avoid a re-check of a image just linked before
        }
    }
}

string SffHandler::scanSff(bool rgbSupported) {
    string str;

    return str;
}
