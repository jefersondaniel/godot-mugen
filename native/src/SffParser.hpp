#ifndef SFF_PARSER_H
#define SFF_PARSER_H

#include <Godot.hpp>
#include <File.hpp>
#include <Image.hpp>
#include <Reference.hpp>

using namespace godot;

class SffParser : public Reference {
    GODOT_CLASS(SffParser, Reference);
public:
    SffParser();

    void _init();

    Variant load_sff(String file);

    static void _register_methods();
};

#endif
