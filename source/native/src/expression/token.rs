use std::cell::RefCell;
use std::rc::{ Rc };
use crate::expression::expression::Expression;
use crate::expression::value::Value;
use crate::expression::parser::{ ParserState, advance, advance_and_expects, advance_and_expects_message, token, expression };

pub enum Token {
    EndToken,
    LiteralToken { value: Value },
    IdentifierToken { name: String },
    BinaryAndUnaryOperatorToken { op: String, precedence: usize, right_associative: bool },
    BinaryOperatorToken { op: String, precedence: usize, right_associative: bool },
    UnaryOperatorToken { op: String, precedence: usize },
    ParenthesisOpenToken,
    ReservedToken { name: String },
    CommaToken,
    IntervalOperatorToken { equality_op: String, start_op: String, end_op: String, min_value: Value, max_value: Value }
}

impl Token {
    pub fn get_type_name(&self) -> String {
        match self {
            Token::EndToken { .. } => "(end)".to_string(),
            Token::LiteralToken { .. } => "(literal)".to_string(),
            Token::IdentifierToken { .. } => "(identifier)".to_string(),
            Token::BinaryAndUnaryOperatorToken { op, .. } => op.to_string(),
            Token::BinaryOperatorToken { op, .. }  => op.to_string(),
            Token::UnaryOperatorToken { op, .. }  => op.to_string(),
            Token::ParenthesisOpenToken => "(".to_string(),
            Token::ReservedToken { name } => name.to_string(),
            Token::CommaToken => ",".to_string(),
            Token::IntervalOperatorToken { .. } => "(interval)".to_string(),
        }
    }

    pub fn get_literal_value(&self) -> Value {
        match self {
            Token::LiteralToken { value } => value.clone(),
            _ => Value::BottomValue
        }
    }

    pub fn get_identifier_name(&self) -> String {
        match self {
            Token::IdentifierToken { name } => name.to_string(),
            _ => "".to_string()
        }
    }

    pub fn lbp(&self) -> usize {
        match self {
            Token::EndToken { .. } => 0,
            Token::LiteralToken { .. } => 5,
            Token::IdentifierToken { .. } => 5,
            Token::BinaryAndUnaryOperatorToken { precedence, .. } => *precedence,
            Token::BinaryOperatorToken { precedence, .. } => *precedence,
            Token::UnaryOperatorToken { precedence, .. } => *precedence,
            Token::ParenthesisOpenToken => 90,
            Token::ReservedToken { .. } => 1,
            Token::CommaToken => 1,
            Token::IntervalOperatorToken { .. } => 50,
        }
    }

    pub fn nud(&self, state_ref: Rc<RefCell<ParserState>>) -> Rc<Expression> {
        match self {
            Token::LiteralToken { value } => Rc::new(Expression::LiteralExpression(value.clone())),
            Token::IdentifierToken { name } => {
                let variable = Rc::new(Expression::VariableExpression(name.to_string()));

                if is_redirection_name(name) && token(Rc::clone(&state_ref)).get_type_name() != "(" {
                    advance_and_expects_message(Rc::clone(&state_ref), ",", "Expected , after redirection keyword");
                    let right = expression(Rc::clone(&state_ref), 5);
                    return Rc::new(Expression::RedirectionExpression(variable, right));
                }

                if token(Rc::clone(&state_ref)).get_type_name() == "(" {
                    advance(Rc::clone(&state_ref));

                    let mut arguments: Vec<Rc<Expression>> = Vec::new();

                    if token(Rc::clone(&state_ref)).get_type_name() != ")" {
                        loop {
                            arguments.push(expression(Rc::clone(&state_ref), 5));
                            if token(Rc::clone(&state_ref)).get_type_name() != "," {
                                break;
                            }
                            advance_and_expects(Rc::clone(&state_ref), ",");
                        }
                        advance_and_expects(Rc::clone(&state_ref), ")");
                    }

                    let is_dynamic_variable: bool = name == "var"
                        || name == "fvar"
                        || is_redirection_name(name);

                    if is_dynamic_variable {
                        if arguments.len() != 1 {
                            let mut state = state_ref.borrow_mut();
                            state.error = format!("Expected exactly one argument at identifier: {}", name);
                            return Rc::new(Expression::BottomExpression);
                        }

                        let dynamic_variable = Rc::new(
                            Expression::DynamicVariableExpression(name.to_string(), Rc::clone(&arguments[0]))
                        );

                        if is_redirection_name(name) {
                            advance_and_expects_message(Rc::clone(&state_ref), ",", "Expected , after redirection keyword");
                            let right = expression(Rc::clone(&state_ref), 5);
                            return Rc::new(Expression::RedirectionExpression(dynamic_variable, right));
                        }

                        return dynamic_variable;
                    }

                    return Rc::new(Expression::FunctionCallExpression(name.to_string(), arguments));
                }

                return variable;
            },
            Token::BinaryAndUnaryOperatorToken { op, .. } => {
                Rc::new(Expression::UnaryOperatorExpression(op.to_string(), expression(state_ref, 100)))
            },
            Token::UnaryOperatorToken { op, .. } => {
                Rc::new(Expression::UnaryOperatorExpression(op.to_string(), expression(state_ref, 100)))
            },
            Token::ParenthesisOpenToken { .. } => {
                let expression = expression(Rc::clone(&state_ref), 5);
                advance_and_expects(Rc::clone(&state_ref), ")");
                expression
            }
            Token::ReservedToken { name } => {
                let mut state = state_ref.borrow_mut();
                state.error = format!("Unexpected token {}", name);
                Rc::new(Expression::BottomExpression)
            },
            Token::CommaToken => {
                let mut state = state_ref.borrow_mut();
                state.error = format!("Unexpected comma");
                Rc::new(Expression::BottomExpression)
            },
            _ => {
                Rc::new(Expression::BottomExpression)
            }
        }
    }

    pub fn led(&self, state_ref: Rc<RefCell<ParserState>>, left: Rc<Expression>) -> Rc<Expression> {
        match self {
            Token::BinaryAndUnaryOperatorToken { op, right_associative, precedence, .. } => {
                let subtract: usize = if *right_associative { 1 } else { 0 };

                Rc::new(Expression::BinaryOperatorExpression(
                    op.to_string(),
                    left,
                    expression(state_ref, precedence - subtract)
                ))
            },
            Token::BinaryOperatorToken { op, right_associative, precedence, .. } => {
                let subtract: usize = if *right_associative { 1 } else { 0 };

                Rc::new(Expression::BinaryOperatorExpression(
                    op.to_string(),
                    left,
                    expression(state_ref, precedence - subtract)
                ))
            },
            Token::ParenthesisOpenToken => {
                let mut state = state_ref.borrow_mut();
                state.error = format!("Unexpected (");
                Rc::new(Expression::BottomExpression)
            },
            Token::ReservedToken { name } => {
                let mut state = state_ref.borrow_mut();
                state.error = format!("Unexpected token {} after {}", name, left.get_type_name());
                Rc::new(Expression::BottomExpression)
            },
            Token::CommaToken => {
                let mut expressions: Vec<Rc<Expression>> = Vec::new();

                expressions.push(left);

                loop {
                    expressions.push(expression(Rc::clone(&state_ref), 5));
                    if token(Rc::clone(&state_ref)).get_type_name() != "," {
                        break;
                    }
                    advance(Rc::clone(&state_ref));
                }

                Rc::new(Expression::ArrayExpression(expressions))
            },
            Token::IntervalOperatorToken { equality_op, start_op, end_op, min_value, max_value, .. } => {
                Rc::new(Expression::IntervalOperatorExpression(
                    equality_op.to_string(),
                    start_op.to_string(),
                    end_op.to_string(),
                    left,
                    min_value.clone(),
                    max_value.clone()
                ))
            },
            _ => Rc::new(Expression::BottomExpression)
        }
    }
}

fn is_redirection_name(name: &str) -> bool {
    name == "parent" || name == "root" || name == "helper" || name == "target" || name == "partner" || name == "enemy" || name == "enemynear" || name == "playerid"
}
