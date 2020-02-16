#include <Godot.hpp>
#include <sstream>
#include "SffParser.hpp"
#include "sff/SffHandler.hpp"
#include "sff/SffFunctions.hpp"

using namespace godot;

SffParser::SffParser()
{
    // pass
}

void SffParser::_init()
{
    // pass
}

Variant SffParser::get_images(String path, Variant selectedPalette)
{
    SffHandler *handler = select_sff_plugin_reader(path);

    if (handler == NULL) {
        return Variant();
    }

    Dictionary result;
    Palette palette;
    int defaultPalette = 0;

    if (selectedPalette.get_type() == Variant::INT) {
        int selectedPaletteIndex = selectedPalette;
        if (selectedPaletteIndex > 0 && selectedPaletteIndex <= handler->paldata.size()) {
            palette = handler->paldata[selectedPaletteIndex - 1].pal;
        } else if (selectedPaletteIndex > 0) {
            Godot::print("Invalid palette index");
        }
    } else if (selectedPalette.get_type() == Variant::STRING) {
        String actExtension = ".act";
        String palettePath = selectedPalette;

        if (palettePath.to_lower().ends_with(actExtension)) {
            palette = loadPalFormatAct(palettePath);
        } else {
            palette = loadPalFormatPal(palettePath);
        }
    }

    for (int i = 0; i < handler->sffdata.size(); i++) {
        if (palette.colors.size() > 0 && handler->sffdata[i].palindex == defaultPalette) {
            handler->sffdata[i].image.setColorTable(palette);
        }
    }

    return create_dictionary(handler->sffdata);
}

Variant SffParser::create_dictionary(std::vector<SffData> sprites)
{
    Dictionary result;

    for (int i = 0; i < sprites.size(); i++) {
        SffData sffData = sprites[i];

        Dictionary dict;
        dict["groupno"] = sffData.groupno;
        dict["imageno"] = sffData.imageno;
        dict["x"] = sffData.x;
        dict["y"] = sffData.y;
        dict["image"] = sffData.image.createImage();

        std::string key = std::to_string(sffData.groupno) + "-" + std::to_string(sffData.imageno);
        result[key.c_str()] = dict;
    }

    return result;
}

void SffParser::_register_methods() {
    register_method("get_images", &SffParser::get_images);
}
