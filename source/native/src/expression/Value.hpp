#ifndef VALUE_HPP
#define VALUE_HPP

#include <iostream>
#include <string>
#include <vector>
#include <Godot.hpp>
#include <Variant.hpp>

using namespace std;
using namespace godot;

class Value {
private:
    int type_;
    int intValue_;
    float floatValue_;
    string stringValue_;
    vector<Value> arrayValue_;
public:
    enum {
        TYPE_BOTTOM,
        TYPE_INT,
        TYPE_FLOAT,
        TYPE_STRING,
        TYPE_ARRAY,
    };

    Value();
    Value(int value);
    Value(float value);
    Value(bool value);
    Value(string value);
    Value(Variant value);
    Value(vector<Value> values);
    int type() const;
    bool isInt() const;
    bool isFloat() const;
    bool isString() const;
    bool isBottom() const;
    bool isArray() const;
    bool isComparable() const;
    bool isArithmetic() const;
    int intValue() const;
    float floatValue() const;
    string stringValue() const;
    operator int() const;
    operator float() const;
    operator bool() const;
    operator Variant() const;

    // Logic
    Value equal(const Value &value) const;
    Value logicalNot() const;
    Value logicalAnd(const Value &value) const;
    Value logicalOr(const Value &value) const;
    Value logicalXor(const Value &value) const;
    Value bitwiseNot() const;
    Value bitwiseAnd(const Value &value) const;
    Value bitwiseOr(const Value &value) const;
    Value bitwiseXor(const Value &value) const;

    // Aritmethic
    Value compare(const Value &value) const;
    Value greater(const Value &value) const;
    Value greaterOrEqual(const Value &value) const;
    Value less(const Value &value) const;
    Value lessOrEqual(const Value &value) const;
    Value add(const Value &value) const;
    Value subtract(const Value &value) const;
    Value inverse() const;
    Value multiply(const Value &value) const;
    Value divide(const Value &value) const;
    Value mod(const Value &value) const;
    Value pow(const Value &value) const;
};

#endif
