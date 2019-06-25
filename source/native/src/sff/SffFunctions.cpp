#include "SffFunctions.hpp"
#include "data/FileStream.hpp"
#include <File.hpp>

Palette loadPalFormatPal(String filename)
{
    Palette pal;

    File* file = File::_new();
    Error error = file->open(filename, File::ModeFlags::READ);

    if (error != Error::OK) {
        Godot::print("Error opening palette file");
        return pal;
    }

    String tmp = file->get_line(); //JASC-PAL
    if (tmp.casecmp_to(String("JASC-PAL")) != 0)
        return pal;
    tmp = file->get_line(); //0100
    tmp = file->get_line(); //256 (colori palette)
    int counter = -1;

    while (!file->eof_reached()) {
        counter++;
        tmp = file->get_line(); //R G B -> valore numerico R, G, B del colore
        PoolRealArray strcolor = tmp.split_floats(" ");
        if (strcolor.size() < 3) {
            Godot::print("Invalid palette line");
            continue;
        }
        pal.colors.push_back(RawColor(strcolor[0], strcolor[1], strcolor[2], 0 == counter ? 0 : 255));
    }

    if (pal.colors.size() == 0) {
        Godot::print("Invalid palette file, no colors");
    }

    file->close();

    return pal;
}

Palette loadPalFormatAct(String filename)
{
    Palette pal;

    File* file = File::_new();
    Error error = file->open(filename, File::ModeFlags::READ);

    if (error != Error::OK) {
        Godot::print("Error opening palette file");
        return pal;
    }

    FileStream in(file);

    uint8_t r, g, b;

    vector<RawColor> reversed;

    for (int a = 0; a < 256; a++) {
        in >> r;
        in >> g;
        in >> b;
        reversed.push_back(RawColor(r, g, b, a == 255 ? 0 : 255));
    }

    for (int i = reversed.size() - 1; i >= 0; i--) {
        pal.colors.push_back(reversed[i]);
    }

    file->close();

    return pal;
}
