#include <Godot.hpp>
#include "PoolByteArrayStream.hpp"

PoolByteArrayStream::PoolByteArrayStream(PoolByteArray array) {
	this->array = array;
	this->buffer = StreamPeerBuffer::_new();
	this->buffer->set_data_array(this->array);
}

bool PoolByteArrayStream::atEnd() {
	return this->buffer->get_available_bytes() <= 0;
}

PoolByteArrayStream &PoolByteArrayStream::operator>>(uint8_t &dest) {
	dest = (uint8_t) this->buffer->get_u8();

	return *this;
}

PoolByteArrayStream &PoolByteArrayStream::operator>>(uint16_t &dest) {
	dest = (uint16_t) this->buffer->get_u16();

	return *this;
}

PoolByteArrayStream &PoolByteArrayStream::operator>>(uint32_t &dest) {
	dest = (uint32_t) this->buffer->get_u32();

	return *this;
}

PoolByteArrayStream &PoolByteArrayStream::operator>>(int8_t &dest) {
	dest = (int8_t) this->buffer->get_8();

	return *this;
}

PoolByteArrayStream &PoolByteArrayStream::operator>>(int16_t &dest) {
	dest = (int16_t) this->buffer->get_16();

	return *this;
}

PoolByteArrayStream &PoolByteArrayStream::operator>>(int32_t &dest) {
	dest = (int32_t) this->buffer->get_32();

	return *this;
}
