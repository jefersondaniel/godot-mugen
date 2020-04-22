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
	ByteArray(vector<uint8_t> &buffer);
	ByteArray(PoolByteArray &array);
    ByteArray(int size, uint8_t placeholder);
	int size() const;
	uint8_t *ptr();
	const uint8_t *ptr() const;
	void append(uint8_t data);
	void append(ByteArray &array);
	void truncate(int size);
	void resize(int size);
	void reserve(int size);
    void fill(uint8_t value);
    void clear();
    ByteArray right(int size);
	ByteArray subarray(int start, int end);
	PoolByteArray toSigned();
	uint8_t operator[](const int idx) const;
	uint8_t& operator[](const int idx);
	void operator=(const ByteArray &p_other);
    bool operator==(const ByteArray &p_other);
	operator PoolByteArray() const;
};

#endif
