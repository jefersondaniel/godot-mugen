#ifndef POOL_BYTE_ARRAY_STREAM_H
#define POOL_BYTE_ARRAY_STREAM_H

#include <Godot.hpp>
#include <StreamPeerBuffer.hpp>

using namespace godot;

class PoolByteArrayStream {
private:
	PoolByteArray array;
	StreamPeerBuffer *buffer;
public:
	PoolByteArrayStream(PoolByteArray array);
	bool atEnd();
	PoolByteArrayStream &operator>>(uint8_t &dest);
	PoolByteArrayStream &operator>>(uint16_t &dest);
	PoolByteArrayStream &operator>>(uint32_t &dest);
	PoolByteArrayStream &operator>>(int8_t &dest);
	PoolByteArrayStream &operator>>(int16_t &dest);
	PoolByteArrayStream &operator>>(int32_t &dest);
};

#endif
