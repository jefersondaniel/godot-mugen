use crate::expressions::expression::Expression;
use crate::expressions::token::Token;
use crate::expressions::tokenizer::tokenize;
use std::cell::RefCell;
use std::rc::Rc;

pub struct ParserState {
    cursor: usize,
    pub error: String,
    tokens: Vec<Rc<Token>>,
}

impl ParserState {
    pub fn new() -> ParserState {
        ParserState {
            cursor: 0,
            tokens: Vec::new(),
            error: "".to_string(),
        }
    }
}

pub fn parse(state_ref: Rc<RefCell<ParserState>>, text: String) -> Rc<Expression> {
    {
        let mut state = state_ref.borrow_mut();
        state.cursor = 0;
        state.error = "".to_string();
    }

    match tokenize(text) {
        Ok(tokens) => {
            {
                let mut state = state_ref.borrow_mut();
                state.tokens = tokens;
            }

            expression(state_ref, 0)
        }
        Err(message) => {
            {
                let mut state = state_ref.borrow_mut();
                state.error = message.to_string();
            }

            Rc::new(Expression::BottomExpression)
        }
    }
}

pub fn advance(state_ref: Rc<RefCell<ParserState>>) {
    let mut state_mut = state_ref.borrow_mut();
    state_mut.cursor += 1
}

pub fn advance_and_expects(state_ref: Rc<RefCell<ParserState>>, type_name: &str) {
    advance_and_expects_message(state_ref, type_name, &format!("Expects: {}", type_name)[..])
}

pub fn advance_and_expects_message(
    state_ref: Rc<RefCell<ParserState>>,
    type_name: &str,
    message: &str,
) {
    if token(Rc::clone(&state_ref)).get_type_name() != type_name {
        let mut state = state_ref.borrow_mut();
        state.error = message.to_string();
    }

    advance(state_ref);
}

pub fn token(state_ref: Rc<RefCell<ParserState>>) -> Rc<Token> {
    {
        let state = state_ref.borrow_mut();

        if state.cursor < state.tokens.len() {
            return Rc::clone(&state.tokens[state.cursor]);
        }
    }

    Rc::new(Token::EndToken)
}

pub fn expression(state_ref: Rc<RefCell<ParserState>>, rbp: usize) -> Rc<Expression> {
    let error_count = { state_ref.borrow().error.len() };

    if error_count > 0 {
        return Rc::new(Expression::BottomExpression);
    }

    let mut left: Rc<Expression>;
    let mut t: Rc<Token> = token(Rc::clone(&state_ref));

    advance(Rc::clone(&state_ref));

    left = t.nud(Rc::clone(&state_ref));

    while rbp < token(Rc::clone(&state_ref)).lbp() {
        t = token(Rc::clone(&state_ref));
        advance(Rc::clone(&state_ref));
        left = t.led(Rc::clone(&state_ref), left);
    }

    left
}
