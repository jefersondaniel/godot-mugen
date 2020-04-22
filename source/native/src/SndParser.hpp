#ifndef SND_PARSER_H
#define SND_PARSER_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <vector>

using namespace godot;

class SndParser : public Reference {
    GODOT_CLASS(SndParser, Reference);
public:
    SndParser();

    void _init();

    Variant get_sounds(String path);

    static void _register_methods();
};

#endif
