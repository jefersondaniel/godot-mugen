use gdnative::prelude::*;
use std::fmt;

pub enum Value {
    IntValue(i64),
    FloatValue(f64),
    StringValue(String),
    ArrayValue(Vec<Value>),
    BottomValue,
}

impl Clone for Value {
    fn clone(&self) -> Value {
        match self {
            Value::IntValue(x) => Value::IntValue(*x),
            Value::FloatValue(x) => Value::FloatValue(*x),
            Value::StringValue(x) => Value::StringValue(x.to_string()),
            Value::ArrayValue(x) => Value::ArrayValue(x.to_vec()),
            Value::BottomValue => Value::BottomValue,
        }
    }
}

impl From<Variant> for Value {
    fn from(variant: Variant) -> Self {
        match variant.get_type() {
            VariantType::Bool => Value::IntValue(if bool::from_variant(&variant).unwrap() {
                1
            } else {
                0
            }),
            VariantType::I64 => Value::IntValue(i64::from_variant(&variant).unwrap()),
            VariantType::F64 => Value::FloatValue(f64::from_variant(&variant).unwrap()),
            VariantType::GodotString => Value::StringValue(String::from_variant(&variant).unwrap()),
            VariantType::VariantArray => {
                let variant_array = VariantArray::from_variant(&variant).unwrap();
                let mut vec: Vec<Value> = Vec::new();
                for item in variant_array.iter() {
                    vec.push(item.into());
                }
                Value::ArrayValue(vec)
            }
            _ => Value::BottomValue,
        }
    }
}

impl ToVariant for Value {
    fn to_variant(&self) -> Variant {
        match self {
            Value::IntValue(x) => Variant::new(*x),
            Value::FloatValue(x) => Variant::new(*x),
            Value::StringValue(x) => Variant::new(x),
            Value::ArrayValue(x) => {
                let array = VariantArray::new();
                for val in x.iter() {
                    array.push(&val.to_variant());
                }
                array.into_shared().to_variant()
            }
            _ => Variant::nil(),
        }
    }
}

impl fmt::Display for Value {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let text = match self {
            Value::FloatValue(x) => x.to_string(),
            Value::IntValue(x) => x.to_string(),
            Value::StringValue(x) => x.to_string(),
            _ => "bottom".to_string(),
        };

        write!(f, "{}", text)
    }
}

impl Value {
    pub fn to_i64(&self) -> i64 {
        match self {
            Value::FloatValue(x) => *x as i64,
            Value::IntValue(x) => *x,
            Value::StringValue(_) => 0,
            _ => 0,
        }
    }

    pub fn to_f64(&self) -> f64 {
        match self {
            Value::IntValue(x) => *x as f64,
            Value::FloatValue(x) => *x,
            Value::StringValue(_) => 0.0,
            _ => 0.0,
        }
    }

    pub fn is_string(&self) -> bool {
        matches!(self, Value::StringValue(_))
    }

    pub fn to_bool(&self) -> bool {
        match self {
            Value::FloatValue(x) => *x != 0.0,
            Value::IntValue(x) => *x != 0,
            Value::StringValue(x) => !x.is_empty(),
            Value::ArrayValue(x) => !x.is_empty(),
            _ => false,
        }
    }

    pub fn is_int(&self) -> bool {
        matches!(self, Value::IntValue(_))
    }

    pub fn is_float(&self) -> bool {
        matches!(self, Value::FloatValue(_))
    }

    pub fn is_bottom(&self) -> bool {
        matches!(self, Value::BottomValue)
    }

    pub fn is_arithmetic(&self) -> bool {
        self.is_int() || self.is_float()
    }

    pub fn is_comparable(&self) -> bool {
        self.is_arithmetic() || self.is_string()
    }

    pub fn equal(&self, other: &Value) -> Value {
        if !self.is_comparable() {
            return Value::BottomValue;
        }

        if self.is_string() || other.is_string() {
            return Value::IntValue(if self.to_string() == other.to_string() {
                1
            } else {
                0
            });
        }

        if self.is_int() && other.is_int() {
            return Value::IntValue(if self.to_i64() == other.to_i64() {
                1
            } else {
                0
            });
        }

        if self.is_float() || other.is_float() {
            return Value::IntValue(if (self.to_f64() - other.to_f64()).abs() < f64::EPSILON {
                1
            } else {
                0
            });
        }

        Value::BottomValue
    }

    pub fn logical_not(&self) -> Value {
        if !self.is_arithmetic() {
            return Value::BottomValue;
        }

        Value::IntValue(if 0 == self.to_i64() { 1 } else { 0 })
    }

    pub fn logical_and(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        Value::IntValue(if self.to_bool() && other.to_bool() {
            1
        } else {
            0
        })
    }

    pub fn logical_or(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        Value::IntValue(if self.to_bool() || other.to_bool() {
            1
        } else {
            0
        })
    }

    pub fn logical_xor(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        Value::IntValue(if self.to_bool() != other.to_bool() {
            1
        } else {
            0
        })
    }

    pub fn bitwise_not(&self) -> Value {
        if self.is_arithmetic() {
            return Value::BottomValue;
        }

        Value::IntValue(!self.to_i64())
    }

    pub fn bitwise_and(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() || !self.is_int() || !other.is_int() {
            return Value::BottomValue;
        }

        Value::IntValue(self.to_i64() & other.to_i64())
    }

    pub fn bitwise_or(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() || !self.is_int() || !other.is_int() {
            return Value::BottomValue;
        }

        Value::IntValue(self.to_i64() | other.to_i64())
    }

    pub fn bitwise_xor(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() || !self.is_int() || !other.is_int() {
            return Value::BottomValue;
        }

        Value::IntValue(self.to_i64() ^ other.to_i64())
    }

    pub fn compare(&self, other: &Value) -> Value {
        if !self.is_comparable() || !other.is_comparable() {
            return Value::BottomValue;
        }

        if self.is_string() || other.is_string() {
            if self.to_string() == other.to_string() {
                return Value::IntValue(0);
            }

            return Value::IntValue(if self.to_string().len() < other.to_string().len() {
                -1
            } else {
                1
            });
        }

        if self.is_int() && other.is_int() {
            if self.to_i64() == other.to_i64() {
                return Value::IntValue(0);
            }

            if self.to_i64() < other.to_i64() {
                return Value::IntValue(-1);
            }

            return Value::IntValue(1);
        }

        if (self.to_f64() - other.to_f64()).abs() < f64::EPSILON {
            return Value::IntValue(0);
        }

        if self.to_f64() < other.to_f64() {
            return Value::IntValue(-1);
        }

        Value::IntValue(1)
    }

    pub fn greater(&self, other: &Value) -> Value {
        let diff = self.compare(other);

        if diff.is_bottom() {
            return diff;
        }

        Value::IntValue(if diff.to_i64() > 0 { 1 } else { 0 })
    }

    pub fn greater_or_equal(&self, other: &Value) -> Value {
        let diff = self.compare(other);

        if diff.is_bottom() {
            return diff;
        }

        Value::IntValue(if diff.to_i64() >= 0 { 1 } else { 0 })
    }

    pub fn less(&self, other: &Value) -> Value {
        let diff = self.compare(other);

        if diff.is_bottom() {
            return diff;
        }

        Value::IntValue(if diff.to_i64() < 0 { 1 } else { 0 })
    }

    pub fn less_or_equal(&self, other: &Value) -> Value {
        let diff = self.compare(other);

        if diff.is_bottom() {
            return diff;
        }

        Value::IntValue(if diff.to_i64() <= 0 { 1 } else { 0 })
    }

    pub fn add(&self, other: &Value) -> Value {
        if self.is_string() || other.is_string() {
            return Value::StringValue(self.to_string() + &other.to_string());
        }

        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        if self.is_int() && other.is_int() {
            return Value::IntValue(self.to_i64() + other.to_i64());
        }

        Value::FloatValue(self.to_f64() + other.to_f64())
    }

    pub fn subtract(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        if self.is_int() && other.is_int() {
            return Value::IntValue(self.to_i64() - other.to_i64());
        }

        Value::FloatValue(self.to_f64() - other.to_f64())
    }

    pub fn inverse(&self) -> Value {
        if !self.is_arithmetic() {
            return Value::BottomValue;
        }

        if self.is_int() {
            return Value::IntValue(-self.to_i64());
        }

        Value::FloatValue(-self.to_f64())
    }

    pub fn modl(&self, other: &Value) -> Value {
        if !self.is_arithmetic()
            || !other.is_arithmetic()
            || self.is_float()
            || other.is_float()
            || other.equal(&Value::IntValue(0)).to_bool()
        {
            return Value::BottomValue;
        }

        Value::IntValue(self.to_i64() % other.to_i64())
    }

    pub fn multiply(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        if self.is_int() && other.is_int() {
            return Value::IntValue(self.to_i64() * other.to_i64());
        }

        Value::FloatValue(self.to_f64() * other.to_f64())
    }

    pub fn divide(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        if self.is_int() && other.is_int() {
            return Value::IntValue(self.to_i64() / other.to_i64());
        }

        Value::FloatValue(self.to_f64() / other.to_f64())
    }

    pub fn pow(&self, other: &Value) -> Value {
        if !self.is_arithmetic() || !other.is_arithmetic() {
            return Value::BottomValue;
        }

        if self.is_int() && other.is_int() {
            return Value::IntValue(self.to_i64().pow(other.to_i64() as u32));
        }

        Value::FloatValue(self.to_f64().powf(other.to_f64()))
    }
}
