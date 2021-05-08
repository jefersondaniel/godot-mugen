#include <cmath>
#include <cerrno>
#include <string>
#include <String.hpp>
#include "Value.hpp"

Value::Value(): type_(Value::TYPE_BOTTOM)
{
}

Value::Value(int value): type_(Value::TYPE_INT), intValue_(value)
{
}

Value::Value(bool value): type_(Value::TYPE_INT), intValue_(value)
{
}

Value::Value(float value): type_(Value::TYPE_FLOAT), floatValue_(value)
{
}

Value::Value(string value): type_(Value::TYPE_STRING), stringValue_(value)
{
}

Value::Value(Variant variant)
{
	if (variant.get_type() == Variant::BOOL) {
        type_ = Value::TYPE_INT;
        intValue_ = variant ? 1 : 0;
    } else if (variant.get_type() == Variant::INT) {
        type_ = Value::TYPE_INT;
        intValue_ = (int) variant;
    } else if (variant.get_type() == Variant::REAL) {
        type_ = Value::TYPE_FLOAT;
        floatValue_ = (float) variant;
    } else if (variant.get_type() == Variant::STRING) {
        type_ = Value::TYPE_STRING;
        String stringValue = variant;
        stringValue_ = string(stringValue.utf8().get_data());
    } else if (variant.get_type() == Variant::ARRAY) {
        type_ = Value::TYPE_ARRAY;
        vector<Value> values_;
        Array array_ = variant;
        for (int i = 0; i < array_.size(); i++) {
            values_.push_back(array_[i]);
        }
        arrayValue_ = values_;
    } else {
        type_ = Value::TYPE_BOTTOM;
    }
}

Value::Value(vector<Value> values_): type_(Value::TYPE_ARRAY), arrayValue_(values_)
{
}

int Value::type() const
{
    return type_;
}

bool Value::isInt() const
{
    return type_ == Value::TYPE_INT;
}

bool Value::isFloat() const
{
    return type_ == Value::TYPE_FLOAT;
}

bool Value::isString() const
{
    return type_ == Value::TYPE_STRING;
}

bool Value::isArray() const
{
    return type_ == Value::TYPE_ARRAY;
}

bool Value::isArithmetic() const
{
    return isInt() || isFloat();
}

bool Value::isComparable() const
{
    return isArithmetic() || isString();
}

bool Value::isBottom() const
{
    return type_ == Value::TYPE_BOTTOM;
}

int Value::intValue() const
{
    if (type_ == Value::TYPE_INT) {
        return intValue_;
    }

    if (type_ == Value::TYPE_FLOAT) {
        return (int) floatValue_;
    }

    return 0;
}

float Value::floatValue() const
{
    if (type_ == Value::TYPE_INT) {
        return (float) intValue_;
    }

    if (type_ == Value::TYPE_FLOAT) {
        return floatValue_;
    }

    return 0.0;
}

string Value::stringValue() const
{
    if (type_ == Value::TYPE_INT) {
        return to_string(intValue_);
    }

    if (type_ == Value::TYPE_FLOAT) {
        return to_string(floatValue_);
    }

    if (type_ == Value::TYPE_STRING) {
        return stringValue_;
    }

    return "";
}

Value Value::equal(const Value &other) const
{
    if (!isComparable() || !other.isComparable()) {
        return Value();
    }

    if (isString() || other.isString()) {
        return Value(stringValue() == other.stringValue());
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() == other.intValue());
    }

    return Value(floatValue() == other.floatValue());
}

Value Value::logicalNot() const
{
    if (!isArithmetic()) {
        return Value();
    }

    return Value(0 == intValue());
}

Value Value::logicalAnd(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    return Value(intValue() && other.intValue());
}

Value Value::logicalOr(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    return Value(intValue() || other.intValue());
}

Value Value::logicalXor(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    return Value(intValue() != other.intValue());
}

Value Value::bitwiseNot() const
{
    if (isArithmetic() || !isArithmetic()) {
        return Value();
    }

    return Value(~intValue());
}

Value Value::bitwiseAnd(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic() || !isInt() || !other.isInt()) {
        return Value();
    }

    return Value(intValue() & other.intValue());
}

Value Value::bitwiseOr(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic() || !isInt() || !other.isInt()) {
        return Value();
    }

    return Value(intValue() | other.intValue());
}

Value Value::bitwiseXor(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic() || !isInt() || !other.isInt()) {
        return Value();
    }

    return Value(intValue() ^ other.intValue());
}

Value Value::compare(const Value &other) const
{
    if (!isComparable() || !other.isComparable()) {
        return Value();
    }

    if (isString() || other.isString()) {
        if (stringValue() == other.stringValue()) {
            return Value(0);
        }

        return Value(stringValue().size() < other.stringValue().size() ? -1 : 1);
    }

    if (isInt() && other.isInt()) {
        if (intValue() == other.intValue()) {
            return Value(0);
        }

        if (intValue() < other.intValue()) {
            return Value(-1);
        }

        return Value(1);
    }

    if (floatValue() == other.floatValue()) {
        return Value(0);
    }

    if (floatValue() < other.floatValue()) {
        return Value(-1);
    }

    return Value(1);
}

Value Value::greater(const Value &value) const
{
    Value diff = compare(value);

    if (diff.isBottom()) {
        return diff;
    }

    return Value(diff.intValue() > 0);
}

Value Value::greaterOrEqual(const Value &value) const
{
    Value diff = compare(value);

    if (diff.isBottom()) {
        return diff;
    }

    return Value(diff.intValue() >= 0);
}

Value Value::less(const Value &value) const
{
    Value diff = compare(value);

    if (diff.isBottom()) {
        return diff;
    }

    return Value(diff.intValue() < 0);
}

Value Value::lessOrEqual(const Value &value) const
{
    Value diff = compare(value);

    if (diff.isBottom()) {
        return diff;
    }

    return Value(diff.intValue() <= 0);
}

Value Value::add(const Value &other) const
{
    if (isString() || other.isString()) {
        return stringValue() + other.stringValue();
    }

    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() + other.intValue());
    }

    return Value(floatValue() + other.floatValue());
}


Value Value::subtract(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    if (isString() || other.isString()) {
        return Value(); // TODO: Review string behavior
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() - other.intValue());
    }

    return Value(floatValue() - other.floatValue());
}

Value Value::inverse() const
{
    if (!isArithmetic()) {
        return Value();
    }

    if (isInt()) {
        return Value(-intValue());
    }

    return Value(-floatValue());
}

Value Value::mod(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic() || isFloat() || other.isFloat() || other.equal(Value(0))) {
        return Value();
    }

    return Value(intValue() % other.intValue());
}

Value Value::multiply(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() * other.intValue());
    }

    return Value(floatValue() * other.floatValue());
}

Value Value::divide(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic() || other.equal(Value(0))) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() / other.intValue());
    }

    return Value(floatValue() / other.floatValue());
}

Value Value::pow(const Value &other) const
{
    if (!isArithmetic() || !other.isArithmetic()) {
        return Value();
    }

    // TODO: Return bottom on invalid pow

    if (isInt() && other.isInt()) {
        return Value((int) std::pow((int) intValue(), (int) other.intValue()));
    }

    return Value((float) std::pow((int) floatValue(), (int) other.floatValue()));
}

Value::operator bool() const
{
    if (!isArithmetic()) {
        return false;
    }

    if (isInt()) {
        return intValue() != 0;
    }

    if (isString()) {
        return stringValue().size() > 0;
    }

    return floatValue() != 0;
}

Value::operator int() const
{
    if (!isArithmetic()) {
        return 0;
    }

    return intValue();
}

Value::operator float() const
{
    if (!isArithmetic()) {
        return 0;
    }

    return floatValue();
}

Value::operator Variant() const
{
    if (isInt()) {
        return Variant(intValue());
    }

    if (isFloat()) {
        return Variant(floatValue());
    }

    if (isString()) {
        return Variant(stringValue().c_str());
    }

    if (isArray()) {
        Array array_;
        for (int i = 0; i < arrayValue_.size(); i++) {
            array_.push_back(arrayValue_[i]);
        }
        return Variant(array_);
    }

    return Variant();
}
