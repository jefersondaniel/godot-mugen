use crate::expressions::context::Context;
use crate::expressions::expression::Expression;
use crate::expressions::parser::{parse, ParserState};
use gdnative::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct MugenExpression {
    error: String,
    state_ref: Rc<RefCell<ParserState>>,
    expression: Rc<Expression>,
}

#[methods]
impl MugenExpression {
    /// The "constructor" of the class.
    fn new(_owner: &Reference) -> Self {
        MugenExpression {
            error: "".to_string(),
            state_ref: Rc::new(RefCell::new(ParserState::new())),
            expression: Rc::new(Expression::BottomExpression),
        }
    }

    #[export]
    fn parse(&mut self, _owner: &Reference, text: String) {
        self.expression = parse(Rc::clone(&self.state_ref), text);
        self.error = self.state_ref.borrow().error.to_string();
    }

    #[export]
    fn execute(&self, _owner: &Reference, context: Variant) -> Variant {
        let context_object = Context::new(context);

        self.expression.evaluate(&context_object).to_variant()
    }

    #[export]
    fn get_error_text(&self, _owner: &Reference) -> String {
        self.error.to_string()
    }

    #[export]
    fn has_error(&self, _owner: &Reference) -> bool {
        !self.error.is_empty()
    }

    #[export]
    fn to_string(&self, _owner: &Reference) -> String {
        self.expression.to_string()
    }
}
