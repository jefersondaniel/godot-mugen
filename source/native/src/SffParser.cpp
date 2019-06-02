#include <Godot.hpp>
#include <Reference.hpp>
#include <Dictionary.hpp>
#include <Color.hpp>
#include <Image.hpp>
#include <vector>
#include <algorithm>
#include <string>
#include "SffParser.hpp"
#include "sff/FileStream.hpp"
#include "sff/ByteArray.hpp"
#include "sff/ByteArrayStream.hpp"
#include "sff/Sffv2.hpp"

using namespace godot;

SffParser::SffParser() {
	// pass
}

void SffParser::_init() {
	// pass
}

Variant SffParser::get_images(String path, int group, int selectedPalette, int defaultPalette) {
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

	Dictionary result;
	std::vector<_SFFV2_PAL_NODE_HEADER> palnode;
	std::vector<_SFFV2_SPRITE_NODE_HEADER> sprnode;

	file->seek(head.first_palnode_offset);

	for(long a=0; a<head.total_palettes; a++) {
		_SFFV2_PAL_NODE_HEADER tmp_palnode;
		in>>tmp_palnode;
		palnode.push_back(tmp_palnode);
	}

	file->seek(head.first_sprnode_offset);
	for(long a=0; a<head.total_frames; a++) {
		_SFFV2_SPRITE_NODE_HEADER tmp_sprnode;
		in>>tmp_sprnode;
		if (group == -1 || group == tmp_sprnode.groupno) {
			sprnode.push_back(tmp_sprnode);
		}
	}

	std::vector<Palette> palettes;

	for(int a = 0; a < palnode.size(); a++) {
		Palette palette;
		palette.groupno = (int) palnode[a].groupno;
		palette.itemno = (int) palnode[a].itemno;
		if(palnode[a].len == 0) {
			palette.colors = palettes[palnode[a].linked].colors;
		}
		if(palnode[a].len > 0) {
			int64_t offset = (int64_t) head.ldata_offset;
			offset += (uint64_t) palnode[a].offset;
			file->seek(offset);
			int k = (int) palnode[a].numcols;
			k = k * 4;
			ByteArray tmpArr;
			in.readRawData(tmpArr, k);
			k = k / 4;
			palette.colors = _sffv2_makeColorArray(tmpArr, k);
		}

		palettes.push_back(palette);
	}

	std::vector<Sprite> sprites;

	for(int a = 0; a < sprnode.size(); a++) {
		int palindex = sprnode[a].palindex;
		if (palindex == defaultPalette && selectedPalette >= 0) {
			palindex = selectedPalette;
		}

		Sprite sprite;
		sprite.groupno = sprnode[a].groupno;
		sprite.imageno = sprnode[a].imageno;
		sprite.w = sprnode[a].w;
		sprite.h = sprnode[a].h;
		sprite.x = sprnode[a].x;
		sprite.y = sprnode[a].y;

		Palette palette = palettes[palindex];

	    if(sprnode[a].len == 0) {
	    	sprite.image = sprites[sprnode[a].linked].image;
	    }

	    if(sprnode[a].len != 0) {
		   uint64_t offset = 0;
		   if(sprnode[a].flags == 0) offset = (uint64_t) head.ldata_offset;
		   if(sprnode[a].flags != 0) offset = (uint64_t) head.tdata_offset;
		   offset += (uint64_t) sprnode[a].offset;
		   file->seek(offset);

	       Image *image;
		   ByteArray tmpArr;
		   in.readRawData(tmpArr, ((int) sprnode[a].len) );

		   if(sprnode[a].fmt == 2) _sffv2_rle8Decode(tmpArr);
	       if(sprnode[a].fmt == 3) _sffv2_rle5Decode(tmpArr);
	       if(sprnode[a].fmt == 4) _sffv2_lz5Decode(tmpArr);

	       if(sprnode[a].colordepth == 5 || sprnode[a].colordepth == 8) {
	          image = _sffv2_makeImage(
	          	tmpArr,
	          	((int) sprnode[a].w),
	            ((int) sprnode[a].h),
	            palette.colors
	          );
	       } else {
	       	  Godot::print("Unsuported color depth");
	       }

		   sprite.image = image;
	    }

		sprites.push_back(sprite);

		Dictionary dict;
		dict["groupno"] = sprite.groupno;
		dict["imageno"] = sprite.imageno;
		dict["w"] = sprite.w;
		dict["h"] = sprite.h;
		dict["x"] = sprite.x;
		dict["y"] = sprite.y;
		dict["image"] = sprite.image;

		std::string key = std::to_string(sprite.groupno) + "-" + std::to_string(sprite.imageno);
		result[key.c_str()] = dict;
	}

	file->close();

	return result;
}

void SffParser::_register_methods() {
	register_method("get_images", &SffParser::get_images);
}
