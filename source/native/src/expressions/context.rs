use crate::expressions::expression::Expression;
use crate::expressions::value::Value;
use gdnative::prelude::*;
use std::rc::Rc;

pub struct Context {
    object: Variant,
}

impl Context {
    pub fn new(object: Variant) -> Context {
        Context { object }
    }

    pub fn godot_call(&self, name: &str, arguments: &[Variant]) -> Option<Variant> {
        let object_ref = self.object.try_to_object::<Object>();

        if object_ref.is_none() {
            godot_print!("invalid_context");
            return Option::None;
        }

        let object = unsafe { object_ref.expect("invalid object ref").assume_safe() };
        let has_method = object.has_method(name);

        if !has_method {
            godot_print!("method_not_found: {}", name);
            return Option::None;
        }

        unsafe { object.call(name, arguments) }.into()
    }

    pub fn get(&self, name: &str) -> Value {
        let result = self.godot_call("get_context_variable", &[name.to_variant()]);

        match result {
            Option::Some(x) => x.into(),
            Option::None => Value::BottomValue,
        }
    }

    pub fn call(&self, name: &str, expressions: &[Rc<Expression>]) -> Value {
        if "cond" == name {
            if expressions.len() == 3 {
                let cond = expressions[0].evaluate(&self);
                if cond.is_bottom() {
                    return Value::BottomValue;
                }
                if cond.to_bool() {
                    return expressions[1].evaluate(&self);
                }
                return expressions[2].evaluate(&self);
            }

            godot_print!(
                "context: invalid argument count for cond function: {}",
                expressions.len()
            );

            return Value::BottomValue;
        }

        if "ifelse" == name {
            if expressions.len() == 3 {
                let cond = expressions[0].evaluate(&self);
                let true_value = expressions[1].evaluate(&self);
                let false_value = expressions[2].evaluate(&self);
                if cond.is_bottom() {
                    return Value::BottomValue;
                }
                return if cond.to_bool() {
                    true_value
                } else {
                    false_value
                };
            }

            godot_print!(
                "context: invalid argument count for ifelse function: {}",
                expressions.len()
            );

            return Value::BottomValue;
        }

        let mut arguments: Vec<Variant> = Vec::new();
        for it in expressions.iter() {
            arguments.push(it.evaluate(&self).to_variant());
        }
        let result = self.godot_call(
            "call_context_function",
            &[name.to_variant(), arguments.to_variant()],
        );

        match result {
            Option::Some(x) => x.into(),
            Option::None => Value::BottomValue,
        }
    }

    pub fn assign(&self, name: &str, value: &Value) {
        self.godot_call(
            "set_context_variable",
            &[name.to_variant(), value.to_variant()],
        );
    }

    pub fn redirect(&self, name: &str) -> Option<Context> {
        let result = self.godot_call("redirect_context", &[name.to_variant()]);

        match result {
            Option::Some(variant) => Option::Some(Context::new(variant)),
            _ => Option::None,
        }
    }
}
