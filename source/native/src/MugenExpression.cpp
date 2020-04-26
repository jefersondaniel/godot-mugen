#include "MugenExpression.hpp"
#include "expression/Context.hpp"

Parser MugenExpression::parser = Parser();

void MugenExpression::_init() {
	// pass
}

void MugenExpression::_register_methods() {
	register_method("parse", &MugenExpression::parse);
    register_method("execute", &MugenExpression::execute);
    register_method("get_error_text", &MugenExpression::get_error_text);
    register_method("to_string", &MugenExpression::to_string);
    register_method("has_error", &MugenExpression::has_error);
}

void MugenExpression::parse(String expression_)
{
    error = "";

    expression = parser.parse(expression_.utf8().get_data());

    if (parser.error.size() > 0) {
        error = parser.error;
    }
}

Variant MugenExpression::execute(Variant context_)
{
    error = "";

    shared_ptr<Context> context(new ObjectContext(context_));

    if (expression == NULL) {
        error = "Expression not parsed";
        return Variant();
    }

    Value result = expression->evaluate(context.get());

    if (result.isBottom()) {
        error = "Expression returned bottom";
    }

    return result;
}

String MugenExpression::get_error_text() const
{
    return error.c_str();
}

bool MugenExpression::has_error() const
{
    return error.size() > 0;
}

String MugenExpression::to_string() const
{
    return String(expression->toString().c_str());
}
