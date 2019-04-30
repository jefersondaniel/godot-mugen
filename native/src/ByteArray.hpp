#ifndef BYTE_ARRAY_H
#define BYTE_ARRAY_H

#include <Godot.hpp>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <vector>

using namespace godot;
using namespace std;

class ByteArray {
private:
public:
	std::vector<uint8_t> _buffer;
	ByteArray();
	ByteArray(const ByteArray &other);
	ByteArray(vector<uint8_t> buffer);
	ByteArray(PoolByteArray &array);
	int size() const;
	void append(uint8_t data);
	void append(ByteArray array);
	void truncate(int size);
	void resize(int size);
	ByteArray subarray(int start, int end);
	uint8_t operator[](const int idx) const;
	uint8_t& operator[](const int idx);
	void operator=(const ByteArray &p_other);
	operator PoolByteArray() const;
};

#endif
