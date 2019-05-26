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

Value::Value(string value): type_(Value::TYPE_INT)
{
    hash<string> hasher;
    intValue_ = hasher(value);
}

Value::Value(Variant variant)
{
    hash<string> hasher;
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
        type_ = Value::TYPE_INT;
        String stringValue = variant;
        intValue_ = hasher(string(stringValue.utf8().get_data()));
    } else {
        type_ = Value::TYPE_BOTTOM;
    }
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


Value Value::equal(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() == other.intValue());
    }

    return Value(floatValue() == other.floatValue());
}

Value Value::logicalNot() const
{
    if (isBottom()) {
        return Value();
    }

    return Value(0 == intValue());
}

Value Value::logicalAnd(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    return Value(intValue() && other.intValue());
}

Value Value::logicalOr(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    return Value(intValue() || other.intValue());
}

Value Value::logicalXor(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    return Value(intValue() != other.intValue());
}

Value Value::bitwiseNot() const
{
    if (isBottom() || !isInt()) {
        return Value();
    }

    return Value(~intValue());
}

Value Value::bitwiseAnd(const Value &other) const
{
    if (isBottom() || other.isBottom() || !isInt() || !other.isInt()) {
        return Value();
    }

    return Value(intValue() & other.intValue());
}

Value Value::bitwiseOr(const Value &other) const
{
    if (isBottom() || other.isBottom() || !isInt() || !other.isInt()) {
        return Value();
    }

    return Value(intValue() | other.intValue());
}

Value Value::bitwiseXor(const Value &other) const
{
    if (isBottom() || other.isBottom() || !isInt() || !other.isInt()) {
        return Value();
    }

    return Value(intValue() ^ other.intValue());
}

Value Value::compare(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
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
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() + other.intValue());
    }

    return Value(floatValue() + other.floatValue());
}


Value Value::subtract(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() - other.intValue());
    }

    return Value(floatValue() - other.floatValue());
}

Value Value::inverse() const
{
    if (isBottom()) {
        return Value();
    }

    if (isInt()) {
        return Value(-intValue());
    }

    return Value(-floatValue());
}

Value Value::mod(const Value &other) const
{
    if (isBottom() || other.isBottom() || isFloat() || other.isFloat() || other.equal(Value(0))) {
        return Value();
    }

    return Value(intValue() % other.intValue());
}

Value Value::multiply(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() * other.intValue());
    }

    return Value(floatValue() * other.floatValue());
}

Value Value::divide(const Value &other) const
{
    if (isBottom() || other.isBottom() || other.equal(Value(0))) {
        return Value();
    }

    if (isInt() && other.isInt()) {
        return Value(intValue() / other.intValue());
    }

    return Value(floatValue() / other.floatValue());
}

Value Value::pow(const Value &other) const
{
    if (isBottom() || other.isBottom()) {
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
    if (isBottom()) {
        return false;
    }

    if (isInt()) {
        return intValue() != 0;
    }

    return floatValue() != 0;
}

Value::operator int() const
{
    if (isBottom()) {
        return 0;
    }

    return intValue();
}

Value::operator float() const
{
    if (isBottom()) {
        return 0;
    }

    return floatValue();
}

Value::operator Variant() const
{
    if (isBottom()) {
        return Variant();
    }

    if (isInt()) {
        return Variant(intValue());
    }

    if (isFloat()) {
        return Variant(floatValue());
    }
}
