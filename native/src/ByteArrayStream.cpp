#include "ByteArrayStream.hpp"
#include "marshalls.hpp"

ByteArrayStream::ByteArrayStream(ByteArray &_data) {
	this->data = _data;
	this->pointer = 0;
}

bool ByteArrayStream::atEnd() {
	return data.size() - pointer <= 0;
}

ByteArrayStream &ByteArrayStream::operator>>(uint8_t &dest) {
	dest = get_u8();

	return *this;
}

ByteArrayStream &ByteArrayStream::operator>>(uint16_t &dest) {
	dest = get_u16();

	return *this;
}

ByteArrayStream &ByteArrayStream::operator>>(uint32_t &dest) {
	dest = get_u32();

	return *this;
}

ByteArrayStream &ByteArrayStream::operator>>(int8_t &dest) {
	dest = get_8();

	return *this;
}

ByteArrayStream &ByteArrayStream::operator>>(int16_t &dest) {
	dest = get_16();

	return *this;
}

ByteArrayStream &ByteArrayStream::operator>>(int32_t &dest) {
	dest = get_32();

	return *this;
}

uint8_t ByteArrayStream::get_u8() {

	uint8_t buf[1];
	get_data(buf, 1);
	return buf[0];
}

int8_t ByteArrayStream::get_8() {

	uint8_t buf[1];
	get_data(buf, 1);
	return buf[0];
}

uint16_t ByteArrayStream::get_u16() {

	uint8_t buf[2];
	get_data(buf, 2);
	uint16_t r = decode_uint16(buf);
	return r;
}

int16_t ByteArrayStream::get_16() {

	uint8_t buf[2];
	get_data(buf, 2);
	uint16_t r = decode_uint16(buf);
	return r;
}

uint32_t ByteArrayStream::get_u32() {

	uint8_t buf[4];
	get_data(buf, 4);
	uint32_t r = decode_uint32(buf);
	return r;
}

int32_t ByteArrayStream::get_32() {

	uint8_t buf[4];
	get_data(buf, 4);
	uint32_t r = decode_uint32(buf);
	return r;
}

void ByteArrayStream::get_data(uint8_t *p_buffer, int p_bytes) {

	int recv;

	get_partial_data(p_buffer, p_bytes, recv);
}

void ByteArrayStream::get_partial_data(uint8_t *p_buffer, int p_bytes, int &r_received) {
	if (pointer + p_bytes > this->data.size()) {
		r_received = this->data.size() - pointer;
		if (r_received <= 0) {
			r_received = 0;
			return;
		}
	} else {
		r_received = p_bytes;
	}

	for (int i = 0; i < r_received; i++) {
		p_buffer[i] = this->data[i + pointer];
	}

	//memcpy(p_buffer, this->data.ptr() + pointer, r_received);

	pointer += r_received;
}
