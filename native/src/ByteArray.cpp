#include "ByteArray.hpp"

ByteArray::ByteArray() {
	_buffer.resize(0);
}


ByteArray::ByteArray(int size) {
	_buffer.resize(size);
}

ByteArray::ByteArray(std::vector<uint8_t> &buffer) {
	_buffer = buffer;
}

ByteArray::ByteArray(const ByteArray &p_other) {
	_buffer.resize(p_other.size());
	for (int i = 0; i < p_other.size(); i++) {
		_buffer[i] = p_other[i];
	}
}

ByteArray::ByteArray(const PoolByteArray array) {
	int size = array.size();
	_buffer.resize(size);

	const unsigned char* array_ptr = array.read().ptr();
	for (int i = 0; i < size; i++) {
		_buffer[i] = array_ptr[i];
	}
}

int ByteArray::size() const {
	return _buffer.size();
}

const uint8_t *ByteArray::ptr() const {
	return &_buffer.front();
}

void ByteArray::resize(int size) {
	_buffer.resize(size);
}

void ByteArray::append(const uint8_t data) {
	_buffer.push_back(data);
}

void ByteArray::append(const ByteArray &array) {
	if (array.size() == 0) {
		return;
	}

	for (int i = 0; i < array.size(); i++) {
		_buffer.push_back(array[i]);
	}
}

void ByteArray::truncate(int newsize) {
	if (size() > newsize) {
		_buffer.resize(newsize);
	}
}

ByteArray ByteArray::subarray(int start, int end) {
	if (start > end || end > size() - 1 || start > size() - 1 || size() == 0) {
		return ByteArray();
	}

	std::vector<uint8_t> newvec;
	newvec.resize(end - start + 1);
	for (int i = start; i <= end; i++) {
		newvec[i] = _buffer[i];
	}

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
  	for (int i = 0; i < _size; i++) {
	    _buffer[i] = p_other[i];
  	}
}

ByteArray::operator PoolByteArray() const {
	PoolByteArray array = PoolByteArray();
	int _size = size();
	array.resize(_size);
	for (int i = 0; i < _size; i++) {
		array.set(i, _buffer[i]);
	}
	return array;
}
