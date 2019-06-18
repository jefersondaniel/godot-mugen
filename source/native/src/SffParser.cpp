#include <Godot.hpp>
#include "SffParser.hpp"
#include "sff/SffHandler.h"

using namespace godot;

SffParser::SffParser() {
    // pass
}

void SffParser::_init() {
    // pass
}

Variant SffParser::get_images(String path, int group, int selectedPalette, int defaultPalette) {
    Godot::print("Selecting plugin");
    SffHandler *handler = select_sff_plugin_reader(path);
    Godot::print("Done reading file");

    if (handler == NULL) {
        return Variant();
    }

    Dictionary result;

    for (int i = 0; i < handler->sffdata.size() - 1; i++) {
        SffData sffData = handler->sffdata[i];

        Dictionary dict;
        dict["groupno"] = sffData.groupno;
        dict["imageno"] = sffData.imageno;
        dict["x"] = sffData.x;
        dict["y"] = sffData.y;
        dict["image"] = sffData.image.createImage();

        std::string key = std::to_string(sffData.groupno) + "-" + std::to_string(sffData.imageno);
        result[key.c_str()] = dict;
    }

    Godot::print("Done converting images");

    cout << "size is " << handler->sffdata.size() << endl;

    return result;
}

void SffParser::_register_methods() {
    register_method("get_images", &SffParser::get_images);
}
