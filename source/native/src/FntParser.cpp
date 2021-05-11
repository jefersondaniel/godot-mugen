#include <Godot.hpp>
#include <File.hpp>
#include "FntParser.hpp"
#include "sff/data/ByteArray.hpp"
#include "sff/data/ByteArrayStream.hpp"
#include "sff/data/FileStream.hpp"
#include "sff/image/RawImage.hpp"
#include "sff/image/PCXReader.hpp"
#include "fnt/structs.h"

using namespace godot;

FntParser::FntParser()
{
    // pass
}

void FntParser::_init()
{
    // pass
}

Variant FntParser::get_font_data(String path)
{
    File* file = File::_new();
    Error error = file->open(path, File::ModeFlags::READ);
    Dictionary result;

    if (error != Error::OK) {
        Godot::print("Error opening fnt file");
        return result;
    }

    FNT_HEADER head;

    FileStream in(file);

    in >> head;

    if (strcmp(&head.signature[0], "ElecbyteFnt") != 0) {
        Godot::print("Invalid fnt signature");
        return result;
    }

    file->seek(head.text_offset);
    ByteArray textArr(head.text_size, 32);
    in.readRawData(textArr, head.text_size);

    file->seek(head.pcx_offset);
    ByteArray pcxArr;
    in.readRawData(pcxArr, head.pcx_size);

    RawImage image;
    PCXReader reader(pcxArr);

    bool success = reader.read(&image);

    if (!success) {
        Godot::print("Invalid pcx image");
        return result;
    }

    result["image"] = image.createImage();
    result["text"] = (PoolByteArray) textArr;

    return result;
}

void FntParser::_register_methods() {
    register_method("get_font_data", &FntParser::get_font_data);
}
