#include "ByteArray.hpp"
#include "ByteArrayStream.hpp"

void printElements(ByteArray &arr) {
	for (int i = 0; i < arr.size(); i++) {
		printf("element[%i] is %i\n",i, arr[i]);
	}
}

ByteArray copy(ByteArray &other) {
	return other;
}

int main() {
	ByteArray bytes1;

	for (int i = 0; i<100; i++) {
		bytes1.append(i);
	}

	bytes1.truncate(75);

	ByteArray bytes2 = bytes1;
	ByteArray bytes3 = bytes2.subarray(10, 74);
	ByteArray bytes4 = bytes2.subarray(0, 63);

	printElements(bytes4);
}
