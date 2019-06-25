#ifndef SFF_PARSER_H
#define SFF_PARSER_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <vector>
#include "sff/SffStructs.hpp"

using namespace godot;

class SffParser : public Reference {
    GODOT_CLASS(SffParser, Reference);
private:
    Variant create_dictionary(std::vector<SffData> sprites);
public:
    SffParser();

    void _init();

    Variant get_images(String path, Variant selectedPalette);

    static void _register_methods();
};

#endif
