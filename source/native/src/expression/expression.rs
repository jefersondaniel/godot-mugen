use std::rc::Rc;
use gdnative::prelude::*;
use crate::expression::value::Value;
use crate::expression::context::Context;

pub enum Expression {
    BottomExpression,
    LiteralExpression(Value),
    VariableExpression(String),
    DynamicVariableExpression(String, Rc<Expression>),
    FunctionCallExpression(String, Vec<Rc<Expression>>),
    BinaryOperatorExpression(String, Rc<Expression>, Rc<Expression>),
    UnaryOperatorExpression(String, Rc<Expression>),
    IntervalOperatorExpression(String, String, String, Rc<Expression>, Value, Value),
    RedirectionExpression(Rc<Expression>, Rc<Expression>),
    ArrayExpression(Vec<Rc<Expression>>),
}

impl Expression {
    pub fn to_string(&self) -> String {
        match self {
            Expression::BottomExpression => "(bottom)".to_string(),
            Expression::LiteralExpression(value) => {
                if value.is_string() {
                    return format!("\"{}\"", value.to_string());
                }

                value.to_string()
            },
            Expression::VariableExpression(name) => name.to_string(),
            Expression::DynamicVariableExpression(base_name, argument) => {
                format!("{}({})", base_name, argument.to_string())
            },
            Expression::FunctionCallExpression(name, expressions) => {
                let argument_names: Vec<String> = expressions.iter()
                    .map(| expression | { expression.to_string() })
                    .collect();

                format!("{}({})", name, argument_names.join(","))
            },
            Expression::BinaryOperatorExpression(op, left, right) => {
                format!("{}{}{}", left.to_string(), op, right.to_string())
            },
            Expression::UnaryOperatorExpression(op, right) => {
                format!("{}{}", op, right.to_string())
            },
            Expression::IntervalOperatorExpression(_, start_op, end_op, _, left, right) => {
                let start = if left.is_string() { format!("\"{}\"", left.to_string()) } else { left.to_string() };
                let end = if right.is_string() { format!("\"{}\"", right.to_string()) } else { right.to_string() };
                return format!("{}{},{}{}", start_op, start, end, end_op)
            },
            Expression::RedirectionExpression(left, right) => {
               format!("({},{})", left.to_string(), right.to_string())
            },
            Expression::ArrayExpression(expressions) => {
                let argument_names: Vec<String> = expressions.iter()
                    .map(| expression | { expression.to_string() })
                    .collect();

                argument_names.join(",")
            },
        }
    }

    pub fn get_type_name(&self) -> String {
        match self {
            Expression::BottomExpression => "(bottom)".to_string(),
            Expression::LiteralExpression(_) => "(literal)".to_string(),
            Expression::VariableExpression(_) => "(variable)".to_string(),
            Expression::DynamicVariableExpression(_, _) => "(dynamic_variable)".to_string(),
            Expression::FunctionCallExpression(_, _) => "(call)".to_string(),
            Expression::BinaryOperatorExpression(_, _, _) => "(operator)".to_string(),
            Expression::UnaryOperatorExpression(_, _) => "(operator)".to_string(),
            Expression::IntervalOperatorExpression(_, _, _, _, _, _) => "(interval)".to_string(),
            Expression::RedirectionExpression(_, _) => "(redirection)".to_string(),
            Expression::ArrayExpression(_) => "(array)".to_string(),
        }
    }

    pub fn evaluate(&self, context: &Context) -> Value {
        match self {
            Expression::BottomExpression => Value::BottomValue,
            Expression::LiteralExpression(value) => value.clone(),
            Expression::VariableExpression(name) => context.get(&name),
            Expression::DynamicVariableExpression(base_name, argument) => {
                let name = &[base_name, &argument.evaluate(context).to_string()[..]].join(".");
                context.get(name)
            },
            Expression::FunctionCallExpression(name, expressions) => {
                context.call(name, &expressions)
            },
            Expression::BinaryOperatorExpression(op, left, right) => {
                match &op[..] {
                    "+" => left.evaluate(context).add(&right.evaluate(context)),
                    "-" => left.evaluate(context).subtract(&right.evaluate(context)),
                    "*" => left.evaluate(context).multiply(&right.evaluate(context)),
                    "/" => left.evaluate(context).divide(&right.evaluate(context)),
                    "**" => left.evaluate(context).pow(&right.evaluate(context)),
                    "%" => left.evaluate(context).modl(&right.evaluate(context)),
                    "=" => left.evaluate(context).equal(&right.evaluate(context)),
                    "!=" => left.evaluate(context).equal(&right.evaluate(context)).logical_not(),
                    ">" => left.evaluate(context).greater(&right.evaluate(context)),
                    ">=" => left.evaluate(context).greater_or_equal(&right.evaluate(context)),
                    "<" => left.evaluate(context).less(&right.evaluate(context)),
                    "<=" => left.evaluate(context).less_or_equal(&right.evaluate(context)),
                    "&&" => left.evaluate(context).logical_and(&right.evaluate(context)),
                    "||" => left.evaluate(context).logical_or(&right.evaluate(context)),
                    "^^" => left.evaluate(context).logical_xor(&right.evaluate(context)),
                    "&" => left.evaluate(context).bitwise_and(&right.evaluate(context)),
                    "|" => left.evaluate(context).bitwise_or(&right.evaluate(context)),
                    "^" => left.evaluate(context).bitwise_xor(&right.evaluate(context)),
                    ":=" => {
                        let assignment = right.evaluate(context);
                        let left_deref: &Expression = &**left;
                        if let Expression::VariableExpression(name) = left_deref {
                            context.assign(&name, &assignment);
                            return assignment;
                        }
                        if let Expression::DynamicVariableExpression(base_name, argument) = left_deref {
                            let name = &[base_name, &argument.evaluate(context).to_string()[..]].join(".");
                            context.assign(name, &assignment);
                            return assignment;
                        }
                        godot_print!("context: invalid left operand for assign");
                        Value::BottomValue
                    },
                    _ => Value::BottomValue,
                }
            },
            Expression::UnaryOperatorExpression(op, right) => {
                match &op[..] {
                    "+" => right.evaluate(context),
                    "-" => right.evaluate(context).inverse(),
                    "~" => right.evaluate(context).bitwise_not(),
                    "!" => right.evaluate(context).logical_not(),
                    _ => Value::BottomValue,
                }
            },
            Expression::IntervalOperatorExpression(op, start_op, end_op, expression, left, right) => {
                let evaluation = expression.evaluate(context);
                let mut after_start = Value::IntValue(0);
                let mut before_end = Value::IntValue(0);

                if start_op == "[" {
                    after_start = evaluation.greater_or_equal(left);
                }

                if start_op == "(" {
                    after_start = evaluation.greater(left);
                }

                if end_op == "]" {
                    before_end = evaluation.less_or_equal(right);
                }

                if end_op == ")" {
                    before_end = evaluation.less(right);
                }

                let in_range = after_start.logical_and(&before_end);

                if op == "=" { in_range } else { in_range.logical_not() }
            },
            Expression::RedirectionExpression(left, right) => {
                let context_name: String;
                let left_deref = &**left;

                if let Expression::VariableExpression(name) = left_deref {
                    context_name = name.to_string();
                } else if let Expression::DynamicVariableExpression(base_name, argument) = left_deref {
                    context_name = [base_name, &argument.evaluate(context).to_string()[..]].join(".");
                } else {
                    return Value::BottomValue;
                }

                match context.redirect(&context_name) {
                    Option::Some(redirected_context) => right.evaluate(&redirected_context),
                    Option::None => Value::BottomValue
                }
            },
            Expression::ArrayExpression(expressions) => {
                let mut values: Vec<Value> = Vec::new();
                for expression in expressions.iter() {
                    values.push(expression.evaluate(context))
                }
                return Value::ArrayValue(values)
            },
        }
    }
}
