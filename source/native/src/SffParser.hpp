#ifndef SFF_PARSER_H
#define SFF_PARSER_H

#include <Godot.hpp>
#include <File.hpp>
#include <Image.hpp>
#include <Reference.hpp>
#include "ByteArray.hpp"

using namespace godot;

struct Sprite {
	int groupno;
	int imageno;
	int w;
	int h;
	int x;
	int y;
	Image* image;
};

struct Palette {
	int groupno;
	int itemno;
	ByteArray colors;
};

class SffParser : public Reference {
    GODOT_CLASS(SffParser, Reference);
public:
    SffParser();

    void _init();

    Variant get_images(String path, int group, int selectedPalette, int defaultPalette);

    static void _register_methods();
};

#endif
