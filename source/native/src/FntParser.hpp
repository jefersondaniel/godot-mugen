#ifndef FNT_PARSER_H
#define FNT_PARSER_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <vector>

using namespace godot;

class FntParser : public Reference {
    GODOT_CLASS(FntParser, Reference);
public:
    FntParser();

    void _init();

    Variant get_font_data(String path);

    static void _register_methods();
};

#endif
