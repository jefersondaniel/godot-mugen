#include <Godot.hpp>
#include "sff/SffHandler.h"

using namespace godot;

SffParser::SffParser() {
    // pass
}

void SffParser::_init() {
    // pass
}

Variant SffParser::get_images(String path, int group, int selectedPalette, int defaultPalette) {
    SffHandler *handler = select_sff_plugin_reader(path);
    handler->read(path);
    Godot::print("Done");
    return Variant();
}

void SffParser::_register_methods() {
    register_method("get_images", &SffParser::get_images);
}
