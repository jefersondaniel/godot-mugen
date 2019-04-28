#include <Godot.hpp>
#include <Reference.hpp>
#include <Dictionary.hpp>
#include <Color.hpp>
#include <Image.hpp>
#include <Texture.hpp>
#include <vector>
#include "SffParser.hpp"
#include "FileStream.hpp"
#include "PoolByteArrayStream.hpp"
#include "Sffv2.hpp"

using namespace godot;

SffParser::SffParser() {
	// pass
}

void SffParser::_init() {
	// pass
}

Variant SffParser::load_sff(String path) {
	Dictionary result;

	File *file = File::_new();
	Error error = file->open(path, File::ModeFlags::READ);

	if (error != Error::OK) {
		Godot::print("Error opening sff file");
		return Variant(false);
	}

	FileStream in(file);
	_SFFV2_SFF_HEADER head;
	in >> head;

	if (strcmp(head.signature, "ElecbyteSpr") != 0 || head.compatverhi != 2) {
		printf("{%s,%d,%d,%d}\n", head.signature, head.compatverhi, head.compatverlo1, head.compatverlo1);
		Godot::print("Invalid sff version, only v2 are supported now");
		return Variant(false);
	}

	std::vector<_SFFV2_PAL_NODE_HEADER> palnode;
	std::vector<_SFFV2_SPRITE_NODE_HEADER> sprnode;

	file->seek(head.first_palnode_offset);

	result["total_palettes"] = head.total_palettes;
	result["total_frames"] = head.total_frames;

	for(long a=0; a<head.total_palettes; a++) {
		_SFFV2_PAL_NODE_HEADER tmp_palnode;
		in>>tmp_palnode; palnode.push_back(tmp_palnode);	  
	}

	file->seek(head.first_sprnode_offset);
	for(long a=0; a<head.total_frames; a++) {
		_SFFV2_SPRITE_NODE_HEADER tmp_sprnode;
		in>>tmp_sprnode; sprnode.push_back(tmp_sprnode);    	  
	}

	Array palettes;

	for(int a = 0; a < palnode.size(); a++) {
		Dictionary sffpal;
		sffpal["groupno"] = (int) palnode[a].groupno;
		sffpal["itemno"] = (int) palnode[a].itemno;
		if(palnode[a].len == 0) {
			sffpal["pal"] = palettes[palnode[a].linked]["pal"];
		}
		if(palnode[a].len > 0) {
			int64_t offset = (int64_t) head.ldata_offset;
			offset += (uint64_t) palnode[a].offset;
			file->seek(offset);

			int k = (int) palnode[a].numcols;
			k = k * 4;
			PoolByteArray tmpArr;
			in.readRawData(tmpArr, k);
			k = k / 4;
			sffpal["pal"] = _sffv2_makeColorArray(tmpArr, k); 
		}

		palettes.push_back(sffpal);
	}

	Array sprites;
	Dictionary spritesDict;

	for(int a = 0; a < sprnode.size(); a++) {
		Dictionary sprite;
		Dictionary currentPalette = palettes[sprnode[a].palindex];
		PoolColorArray colors = currentPalette["pal"];

		sprite["groupno"] = sprnode[a].groupno;
		sprite["imageno"] = sprnode[a].imageno;
		sprite["w"] = sprnode[a].w;
		sprite["h"] = sprnode[a].h;
		sprite["x"] = sprnode[a].x;
		sprite["y"] = sprnode[a].y;

	    if(sprnode[a].len == 0) {
		  sprite["image"] = sprites[sprnode[a].linked]["image"];    
	    }
	    if(sprnode[a].len != 0) {
		   uint64_t offset = 0;
		   if(sprnode[a].flags == 0) offset = (uint64_t) head.ldata_offset;
		   if(sprnode[a].flags != 0) offset = (uint64_t) head.tdata_offset;
		   offset += (uint64_t) sprnode[a].offset;
		   file->seek(offset);

	       Image *img;
		   PoolByteArray tmpArr;
		   in.readRawData(tmpArr, ((int) sprnode[a].len) );

		   std::string message = "{groupno:" + std::to_string(sprnode[a].groupno) + "," +  
		   	"imageno:" + std::to_string(sprnode[a].imageno) + "," +  
		   	"offset:" + std::to_string(sprnode[a].offset) + "," +  
		   	"fmt:" + std::to_string(sprnode[a].fmt) + "," +  
		   	"w:" + std::to_string(sprnode[a].w) + "," +  
		   	"h:" + std::to_string(sprnode[a].h) + "," +  
		   	"palindex:" + std::to_string(sprnode[a].palindex) + "}";  
		   Godot::print(message.c_str());

		   if(sprnode[a].fmt == 2) _sffv2_rle8Decode(tmpArr);
	       if(sprnode[a].fmt == 3) _sffv2_rle5Decode(tmpArr);
	       if(sprnode[a].fmt == 4) _sffv2_lz5Decode(tmpArr);

	       if(sprnode[a].colordepth == 5 || sprnode[a].colordepth == 8) {
	          img = _sffv2_makeImage(
	          	tmpArr,
	          	((int) sprnode[a].w), 
	            ((int) sprnode[a].h),
	            colors
	          );
	       }
		   
		   sprite["image"] = img;
		   tmpArr.resize(0);
	    }

		std::string key = std::to_string(sprnode[a].groupno) + "-" + std::to_string(sprnode[a].imageno);
		spritesDict[key.c_str()] = sprite;
		sprites.push_back(sprite);
	}

	file->close();

	result["palettes"] = palettes;
	result["sprites"] = spritesDict;

	return Variant(result);
}

void SffParser::_register_methods() {
	register_method("load_sff", &SffParser::load_sff);
}
