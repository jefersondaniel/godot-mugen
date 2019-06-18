#ifndef SFF_PARSER_H
#define SFF_PARSER_H

#include <Godot.hpp>
#include <File.hpp>
#include <Image.hpp>
#include <Reference.hpp>
#include "sff/data/ByteArray.hpp"

using namespace godot;

class SffParser : public Reference {
    GODOT_CLASS(SffParser, Reference);
public:
    SffParser();

    void _init();

    Variant get_images(String path, int group, int selectedPalette, int defaultPalette);

    static void _register_methods();
};

#endif
