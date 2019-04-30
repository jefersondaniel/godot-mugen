#include "ByteArray.hpp"

ByteArray::ByteArray() {
}

ByteArray::ByteArray(vector<uint8_t> newbuffer) {
	_buffer = newbuffer;
}

ByteArray::ByteArray(const ByteArray &p_other) {
  	int _size = p_other.size();
  	resize(_size);
  	for (int i = 0; i < _size; i++) {
	    _buffer[i] = p_other[i];
  	}
}

ByteArray::ByteArray(PoolByteArray &_arr) {

	int size = _arr.size();
	resize(size);

	for (int i = 0; i < size; i++) {
		_buffer[i] = _arr[i];
	}
}

int ByteArray::size() const {
	return _buffer.size();
}

void ByteArray::resize(int _size) {
	_buffer.resize(_size);
}

void ByteArray::append(uint8_t data) {
	_buffer.push_back(data);
}

void ByteArray::append(ByteArray array) {
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

	for (int i = start; i <= end; i++) {
		newvec.push_back(_buffer[i]);
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
