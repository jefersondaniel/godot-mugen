#include <Godot.hpp>
#include <File.hpp>
#include "FileStream.hpp"

FileStream::FileStream(File *file) {
	this->file = file;
}

void FileStream::readRawData(char *dest, size_t length) {
	PoolByteArray buffer = this->file->get_buffer(length);
	memcpy(dest, buffer.read().ptr(), length);
}

void FileStream::readRawData(PoolByteArray &dest, size_t length) {
	dest = this->file->get_buffer(length);
}

FileStream &FileStream::operator>>(uint8_t &dest) {
	dest = (uint8_t) this->file->get_8();

	return *this;
}

FileStream &FileStream::operator>>(uint16_t &dest) {
	dest = (uint16_t) this->file->get_16();

	return *this;
}

FileStream &FileStream::operator>>(uint32_t &dest) {
	dest = (uint32_t) this->file->get_32();

	return *this;
}

FileStream &FileStream::operator>>(int8_t &dest) {
	dest = (int8_t) this->file->get_8();

	return *this;
}

FileStream &FileStream::operator>>(int16_t &dest) {
	dest = (int16_t) this->file->get_16();

	return *this;
}

FileStream &FileStream::operator>>(int32_t &dest) {
	dest = (int32_t) this->file->get_32();

	return *this;
}
