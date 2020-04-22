#ifndef BYTE_ARRAY_STREAM_H
#define BYTE_ARRAY_STREAM_H

#include "ByteArray.hpp"

/**
 * Stream Reader, handles only little endian data
 */
class ByteArrayStream {
private:
	ByteArray data;
	int size;
	int position;
	void get_partial_data(uint8_t *p_buffer, int p_bytes, int &r_received);
public:
	ByteArrayStream(ByteArray &data);
	bool atEnd() const;
    int pos() const;
    void seek(int position);
	void get_data(uint8_t *p_buffer, int p_bytes);
	ByteArrayStream &operator>>(uint8_t &dest);
	ByteArrayStream &operator>>(uint16_t &dest);
	ByteArrayStream &operator>>(uint32_t &dest);
	ByteArrayStream &operator>>(int8_t &dest);
	ByteArrayStream &operator>>(int16_t &dest);
	ByteArrayStream &operator>>(int32_t &dest);
	uint8_t get_u8();
	int8_t get_8();
	uint16_t get_u16();
	int16_t get_16();
	uint32_t get_u32();
	int32_t get_32();
};

#endif
