#include <Godot.hpp>
#include <File.hpp>
#include "SndParser.hpp"
#include "sff/data/ByteArray.hpp"
#include "sff/data/ByteArrayStream.hpp"
#include "sff/data/FileStream.hpp"
#include "snd/structs.h"

using namespace godot;

SndParser::SndParser()
{
    // pass
}

void SndParser::_init()
{
    // pass
}

Variant SndParser::get_sounds(String path)
{
    File* file = File::_new();
    Error error = file->open(path, File::ModeFlags::READ);
    Dictionary result;

    if (error != Error::OK) {
        Godot::print("Error opening snd file");
        return result;
    }

    SND_HEADER head;

    FileStream in(file);

    in >> head;

    if (strcmp(&head.signature[0], "ElecbyteSnd") != 0) {
        Godot::print("Invalid snd signature");
        return result;
    }

    file->seek(head.subheader_offset);

    for (int i = 0; i < 4096; i++) {
        SND_SUBHEADER subheader;
        in >> subheader;

        if (subheader.length == 0) {
            break;
        }

        ByteArray tmpArr;
        in.readRawData(tmpArr, subheader.length);

        ByteArrayStream tmpArrayStream = ByteArrayStream(tmpArr);
        WAV_HEADER wavHeader;
        tmpArrayStream >> wavHeader;

        Dictionary dict;
        dict["groupno"] = subheader.groupno;
        dict["soundno"] = subheader.soundno;
        dict["audio_format"] = wavHeader.audioFormat;
        dict["num_channels"] = wavHeader.numChannels;
        dict["sample_rate"] = wavHeader.sampleRate;
        dict["byte_rate"] = wavHeader.byteRate;
        dict["block_align"] = wavHeader.blockAlign;
        dict["bits_per_sample"] = wavHeader.bitsPerSample;
        dict["data"] = tmpArr.toSigned();

        std::string key = std::to_string(subheader.groupno) + "-" + std::to_string(subheader.soundno);
        result[key.c_str()] = dict;

        tmpArr.clear();

        if (subheader.next > 0 && subheader.next < file->get_len()) {
            file->seek(subheader.next);
        } else {
            break;
        }
    }

    file->close();

    return result;
}

void SndParser::_register_methods() {
    register_method("get_sounds", &SndParser::get_sounds);
}
