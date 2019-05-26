#include <cmath>
#include "Expression.hpp"

// Expression

Expression::Expression(string type_): type(type_)
{
}

Value Expression::evaluate(Context* context)
{
    return Value(0);
}

BottomExpression::BottomExpression(): Expression("(bottom)")
{
}

Value BottomExpression::evaluate(Context* context)
{
    return Value();
}

// LiteralExpression

LiteralExpression::LiteralExpression(Value value_): Expression("(literal)"), value(value_)
{
}

Value LiteralExpression::evaluate(Context* context)
{
    return value;
}

// VariableExpression

VariableExpression::VariableExpression(string name_): Expression("(variable)"), name(name_)
{
}

Value VariableExpression::evaluate(Context* context)
{
    return context->get(name);
}

// DynamicVariableExpression

DynamicVariableExpression::DynamicVariableExpression(string name_, shared_ptr<Expression> argument_): Expression("(dynamic_variable)"), baseName(name_), argument(argument_)
{
}

string DynamicVariableExpression::getName(Context* context)
{
    return baseName + "." + to_string(argument->evaluate(context).intValue());
}

Value DynamicVariableExpression::evaluate(Context* context)
{
    return context->get(getName(context));
}

// FunctionCalExpression

FunctionCallExpression::FunctionCallExpression(string name_, vector<shared_ptr<Expression>> arguments_): Expression("call"), name(name_), arguments(arguments_)
{
}

Value FunctionCallExpression::evaluate(Context* context)
{
    vector<shared_ptr<Expression>> evaluatedArguments;
    for (int i = 0; i < arguments.size(); i++) {
        evaluatedArguments.push_back(arguments[i]);
    }
    return context->call(name, evaluatedArguments);
}

// BinaryOperatorExpression

BinaryOperatorExpression::BinaryOperatorExpression(
    string op_,
    shared_ptr<Expression> left_,
    shared_ptr<Expression> right_
): Expression("(operator)"), op(op_), left(left_), right(right_) {
}

Value BinaryOperatorExpression::evaluate(Context* context)
{
    if (op == "+")
        return left->evaluate(context).add(right->evaluate(context));
    if (op == "-")
        return left->evaluate(context).subtract(right->evaluate(context));
    if (op == "*")
        return left->evaluate(context).multiply(right->evaluate(context));
    if (op == "/")
        return left->evaluate(context).divide(right->evaluate(context));
    if (op == "**")
        return left->evaluate(context).pow(right->evaluate(context));
    if (op == "%")
        return left->evaluate(context).mod(right->evaluate(context));
    if (op == "=")
        return left->evaluate(context).equal(right->evaluate(context));
    if (op == "!=")
        return left->evaluate(context).equal(right->evaluate(context)).logicalNot();
    if (op == ">")
        return left->evaluate(context).greater(right->evaluate(context));
    if (op == ">=")
        return left->evaluate(context).greaterOrEqual(right->evaluate(context));
    if (op == "<")
        return left->evaluate(context).less(right->evaluate(context));
    if (op == "<=")
        return left->evaluate(context).lessOrEqual(right->evaluate(context));
    if (op == "&&")
        return left->evaluate(context).logicalAnd(right->evaluate(context));
    if (op == "||")
        return left->evaluate(context).logicalOr(right->evaluate(context));
    if (op == "^^")
        return left->evaluate(context).logicalXor(right->evaluate(context));
    if (op == "&")
        return left->evaluate(context).bitwiseAnd(right->evaluate(context));
    if (op == "|")
        return left->evaluate(context).bitwiseOr(right->evaluate(context));
    if (op == "^")
        return left->evaluate(context).bitwiseXor(right->evaluate(context));
    if (op == ":=") {
        Value assignment = right->evaluate(context);
        if (left->type == "(variable)") {
            shared_ptr<VariableExpression> variable = dynamic_pointer_cast<VariableExpression>(left);
            context->assign(variable->name, assignment);
            return assignment;
        } else if (left->type == "(dynamic_variable)") {
            shared_ptr<DynamicVariableExpression> variable = dynamic_pointer_cast<DynamicVariableExpression>(left);
            context->assign(variable->getName(context), assignment);
            return assignment;
        }
        cerr << "context: invalid left operand for assign: " << left->type << endl;
        return Value();
    }
    cerr << "invalid operator: " << op << endl;
    return 0;
}

// UnaryOperatorExpression

UnaryOperatorExpression::UnaryOperatorExpression(
    string op_,
    shared_ptr<Expression> right_
): Expression("(operator)"), op(op_), right(right_) {
}

Value UnaryOperatorExpression::evaluate(Context* context)
{
    if (op == "+")
        return right->evaluate(context);
    if (op == "-")
        return right->evaluate(context).inverse();
    if (op == "~")
        return right->evaluate(context).bitwiseNot();
    if (op == "!")
        return right->evaluate(context).logicalNot();
    cerr << "Invalid operator: " << op << endl;
    return Value(0);
}

// IntervalOperatorExpression

IntervalOperatorExpression::IntervalOperatorExpression(
    string op_,
    string startOp_,
    string endOp_,
    shared_ptr<Expression> value_,
    Value left_,
    Value right_
): Expression("(interval)"), op(op_), startOp(startOp_), endOp(endOp_), value(value_), left(left_), right(right_) {
}

Value IntervalOperatorExpression::evaluate(Context* context)
{
    Value evaluation = value->evaluate(context);
    Value afterStart(0);
    Value beforeEnd(0);

    if (startOp == "[") {
        afterStart = evaluation.greaterOrEqual(left);
    }

    if (startOp == "(") {
        afterStart = evaluation.greater(left);
    }

    if (endOp == "]") {
        beforeEnd = evaluation.lessOrEqual(right);
    }

    if (endOp == ")") {
        beforeEnd = evaluation.less(right);
    }

    Value inRange = afterStart.logicalAnd(beforeEnd);

    return op == "=" ? inRange : inRange.logicalNot();
}

// RedirectionExpression

RedirectionExpression::RedirectionExpression(shared_ptr<Expression> left_, shared_ptr<Expression> right_): Expression("(redirection)"), left(left_), right(right_)
{
}

Value RedirectionExpression::evaluate(Context* context)
{
    string contextName;

    if (left->type == "(variable)") {
        contextName = dynamic_pointer_cast<VariableExpression>(left)->name;
    } else if (left->type == "(dynamic_variable)") {
        contextName = dynamic_pointer_cast<DynamicVariableExpression>(left)->getName(context);
    } else {
        return Value();
    }

    shared_ptr<Context> redirect = context->redirect(contextName);

    if (redirect == NULL) {
        return Value();
    }

    return right->evaluate(redirect.get());
}
