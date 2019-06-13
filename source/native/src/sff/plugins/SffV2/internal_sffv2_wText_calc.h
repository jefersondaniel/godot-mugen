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

string _sffv2_wText_file_calc(int groupno, int imageno, const string & _imageFormat) {
  //note this is identical to _sffv1_wText_file_calc but it is duplicated due to avoid cross-conflicts
  string result;
    if(groupno < 1000) result += "0";
    if(groupno < 100) result += "0";
    if(groupno < 10) result += "0";
    {
	  result += to_str(groupno);
    }
    result += "-";
    if(imageno < 10) result += "0";
    {
	  result += to_str(imageno);
    }
    result += "."; result += _imageFormat;
  return result;
}

