#include "ByteArray.hpp"

ByteArray::ByteArray() {
}

ByteArray::ByteArray(vector<uint8_t> &newbuffer) {
	_buffer = newbuffer;
}

ByteArray::ByteArray(const ByteArray &p_other) {
	int _size = p_other.size();
	resize(_size);
	memcpy(&_buffer.front(), p_other.ptr(), _size);
}

ByteArray::ByteArray(PoolByteArray &_arr) {
	int size = _arr.size();
	resize(size);
	memcpy(&_buffer.front(), _arr.read().ptr(), size);
}

int ByteArray::size() const {
	return _buffer.size();
}

uint8_t *ByteArray::ptr() {
	return &_buffer.front();
}

const uint8_t *ByteArray::ptr() const {
	return &_buffer.front();
}

void ByteArray::resize(int _size) {
	_buffer.resize(_size);
}

void ByteArray::reserve(int _size) {
	_buffer.reserve(_size);
}

void ByteArray::append(uint8_t data) {
	_buffer.push_back(data);
}

void ByteArray::append(ByteArray &other) {
	int otherSize = other.size();
	int mySize = size();

	if (otherSize == 0) {
		return;
	}

	resize(mySize + otherSize);
	memcpy(ptr() + mySize, other.ptr(), otherSize);
}

void ByteArray::truncate(int newsize) {
	if (size() > newsize) {
		_buffer.resize(newsize);
	}
}

ByteArray ByteArray::subarray(int start, int end) {
	int mysize = size();
	int newsize = end - start + 1;

	if (start > end || end > mysize - 1 || start > mysize - 1 || mysize == 0) {
		return ByteArray();
	}

	std::vector<uint8_t> newvec;
	newvec.resize(newsize);
	memcpy(&newvec[0], &_buffer[start], newsize);

	return ByteArray(newvec);
}

uint8_t ByteArray::operator[](const int idx) const {
	return _buffer[idx];
}

uint8_t &ByteArray::operator[](const int idx) {
	return _buffer[idx];
}

void ByteArray::operator=(const ByteArray &p_other) {
	int _size = p_other.size();
	resize(_size);
	memcpy(&_buffer.front(), p_other.ptr(), _size);
}

ByteArray::operator PoolByteArray() const {
	PoolByteArray array = PoolByteArray();
	int _size = size();
	array.resize(_size);
	memcpy(array.write().ptr(), &_buffer.front(), _size);
	return array;
}
