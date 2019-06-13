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

#include "Sff.h"
#include "SffHandler.h"


Sff::~Sff() {
  sffdata.clear();
  paldata.clear();
}


Sff::Sff() {
  this->clear();
  this->removeDuplicates = true; this->format = 1;
}


void Sff::clear() {
  sffdata.clear();
  paldata.clear();
  isSaved = true;
  actualImage = -1;
  filename = "";
}


bool Sff::loadSff(String & _filename) {
  SffHandler * sffh = select_sff_plugin_reader(_filename);
  //select_sff_plugin_reader automaticly invoke PLUGIN->read(filename) so it
  //is not necessary to call it inside loadSff

  if(sffh == NULL) {
    actualImage = -1; return false;
  }
  sffdata = sffh->sffdata;
  paldata = sffh->paldata;
  delete sffh;
  isSaved = true;
  filename = _filename;
  actualImage = 0;
  return true;
}

SffData * Sff::item(int itemID) {
  return &sffdata[itemID];
}

int Sff::searchItem(int groupno, int imageno) {
  for(int a = 0; a < sffdata.size(); a++) {
    if(sffdata[a].groupno == groupno && sffdata[a].imageno == imageno) return a;
  }
  return -1;
}

int Sff::searchItem(int groupno) {
  for(int a = 0; a < sffdata.size(); a++) {
    if(sffdata[a].groupno == groupno) return a;
  }
  return -1;
}

vector<int> Sff::usedPalGroups() {
  vector<int> values;
  for(int a=0; a<paldata.size(); a++) {
	bool new_value=true;
    for(int b=0; b<values.size(); b++) {
	  if(paldata[a].groupno == values[b]) { new_value=false; break; }
    }
    if(new_value==true) { values.push_back(paldata[a].groupno); }
  }
  return values;
}


void Sff::resyncPaletteAfterRemoveItem(int index) {
  for(int a = 0; a<paldata.size(); a++) {
    if(paldata[a].isUsed == true && paldata[a].usedby == index) {
	  paldata[a].isUsed = false;
	  for(int b=index; b<sffdata.size(); b++) {
	  	 if(sffdata[b].palindex == a) { paldata[a].isUsed = true; paldata[a].usedby = b; break; }
      }
    }
    if(paldata[a].isUsed == true && paldata[a].usedby > index) paldata[a].usedby--;
  }
}

