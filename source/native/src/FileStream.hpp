#ifndef FILE_STREAM_H
#define FILE_STREAM_H

#include <Godot.hpp>
#include <File.hpp>
#include "ByteArray.hpp"

using namespace godot;

class FileStream {
private:
	File *file;
public:
	FileStream(File *file);
	void readRawData(char *buffer, size_t length);
	void readRawData(ByteArray &dest, size_t length);
	FileStream &operator>>(uint8_t &dest);
	FileStream &operator>>(uint16_t &dest);
	FileStream &operator>>(uint32_t &dest);
	FileStream &operator>>(int8_t &dest);
	FileStream &operator>>(int16_t &dest);
	FileStream &operator>>(int32_t &dest);
};

#endif
