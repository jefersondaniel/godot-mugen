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

    #[method]
    fn parse(&mut self, text: String) {
        self.expression = parse(Rc::clone(&self.state_ref), text);
        self.error = self.state_ref.borrow().error.to_string();
    }

    #[method]
    fn execute(&self, context: Variant) -> Variant {
        let context_object = Context::new(context);

        self.expression.evaluate(&context_object).to_variant()
    }

    #[method]
    fn get_error_text(&self) -> String {
        self.error.to_string()
    }

    #[method]
    fn has_error(&self) -> bool {
        !self.error.is_empty()
    }

    #[method]
    fn to_string(&self) -> String {
        self.expression.to_string()
    }
}
