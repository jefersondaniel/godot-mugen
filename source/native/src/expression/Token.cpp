#include "Token.hpp"
#include "Expression.hpp"
#include <memory>
#include <Godot.hpp>

#define IS_REDIRECTION_NAME(name) (name == "parent" || name == "root" || name == "helper" || name == "target" || name == "partner" || name == "enemy" || name == "enemynear" || name == "playerid")

// Token

Token::Token(Parser* parser_, string type_, int lbp_): parser(parser_), type(type_), lbp(lbp_)
{
}

shared_ptr<Expression> Token::nud()
{
    return shared_ptr<Expression>(new Expression("(undefined)"));
}

shared_ptr<Expression> Token::led(shared_ptr<Expression> left)
{
    return left;
}

// LiteralToken

LiteralToken::LiteralToken(Parser* parser_, Value value_): Token(parser_, "(literal)", 5), value(value_)
{
}

shared_ptr<Expression> LiteralToken::nud()
{
    return shared_ptr<Expression>(new LiteralExpression(value));
}

// IdentifierToken

IdentifierToken::IdentifierToken(Parser* parser_, string name_): Token(parser_, "(identifier)", 5), name(name_)
{
}

shared_ptr<Expression> IdentifierToken::nud()
{
    shared_ptr<Expression> variable(new VariableExpression(name));

    if (IS_REDIRECTION_NAME(name) && parser->token()->type != "(") {
        parser->advance(",", "Expected , after redirection keyword");
        shared_ptr<Expression> right = parser->expression(5);
        return shared_ptr<Expression>(new RedirectionExpression(variable, right));
    }

    if (parser->token()->type == "(") {
        parser->advance();

        vector<shared_ptr<Expression>> arguments;

        if (parser->token()->type != ")") {
            while (true) {
                arguments.push_back(parser->expression(5));
                if (parser->token()->type != ",") {
                    break;
                }
                parser->advance(",");
            }
            parser->advance(")");
        }

        bool isDynamicVariable = name == "var"
            || name == "fvar"
            || IS_REDIRECTION_NAME(name);

        if (isDynamicVariable) {
            if (arguments.size() != 1) {
                parser->setError("Expected exactly one argument at identifier: " + name);
                return shared_ptr<Expression>(new BottomExpression());
            }

            shared_ptr<Expression> dynamicVariable(new DynamicVariableExpression(
                name,
                arguments[0]
            ));

            if (IS_REDIRECTION_NAME(name)) {
                parser->advance(",", "Expected , after redirection keyword");
                shared_ptr<Expression> right = parser->expression(5);
                return shared_ptr<Expression>(new RedirectionExpression(dynamicVariable, right));
            }

            return dynamicVariable;
        }

        return shared_ptr<Expression>(new FunctionCallExpression(name, arguments));
    }

    return variable;
}

// BinaryAndUnaryOperatorToken

BinaryAndUnaryOperatorToken::BinaryAndUnaryOperatorToken(Parser* parser_, string op_, int precedence_, bool rightAssociative_): Token(parser_, op_, precedence_), op(op_), precedence(precedence_), rightAssociative(rightAssociative_)
{
}

shared_ptr<Expression> BinaryAndUnaryOperatorToken::nud()
{
    return shared_ptr<Expression>(new UnaryOperatorExpression(op, parser->expression(100)));
}

shared_ptr<Expression> BinaryAndUnaryOperatorToken::led(shared_ptr<Expression> left)
{
    int subtract = rightAssociative ? 1 : 0;

    return shared_ptr<Expression>(new BinaryOperatorExpression(op, left, parser->expression(precedence - subtract)));
}

// BinaryOperatorToken

BinaryOperatorToken::BinaryOperatorToken(Parser* parser_, string op_, int precedence_, bool rightAssociative_): Token(parser_, op_, precedence_), op(op_), precedence(precedence_), rightAssociative(rightAssociative_)
{
}

shared_ptr<Expression> BinaryOperatorToken::led(shared_ptr<Expression> left)
{
    int subtract = rightAssociative ? 1 : 0;
    shared_ptr<Expression> right = parser->expression(precedence - subtract);

    return shared_ptr<Expression>(new BinaryOperatorExpression(op, left, right));
}

// UnaryOperatorToken

UnaryOperatorToken::UnaryOperatorToken(Parser* parser_, string op_, int precedence_): Token(parser_, op_, precedence_), op(op_), precedence(precedence_)
{
}

shared_ptr<Expression> UnaryOperatorToken::nud()
{
    return shared_ptr<Expression>(new UnaryOperatorExpression(op, parser->expression(100)));
}

// EndToken

EndToken::EndToken(Parser* parser_): Token(parser_, "(end)", 0)
{
}

// ReservedToken

ReservedToken::ReservedToken(Parser* parser_, string type_): Token(parser_, type_, 1)
{
}

shared_ptr<Expression> ReservedToken::nud()
{
    parser->setError("Unexpected " + type);
    return shared_ptr<Expression>(new BottomExpression());
}

shared_ptr<Expression> ReservedToken::led(shared_ptr<Expression> left)
{
    parser->setError("Unexpected " + type + " after " + left->type);
    return shared_ptr<Expression>(new BottomExpression());
}

// CommaToken

CommaToken::CommaToken(Parser* parser_): Token(parser_, ",", 1)
{
}

shared_ptr<Expression> CommaToken::nud()
{
    parser->setError("Unexpected comma");
    return shared_ptr<Expression>(new BottomExpression());
}

shared_ptr<Expression> CommaToken::led(shared_ptr<Expression> left)
{
    vector<shared_ptr<Expression>> expressions;

    expressions.push_back(left);

    while (true) {
        expressions.push_back(parser->expression(5));
        if (parser->token()->type != ",") {
            break;
        }
        parser->advance();
    }

    return shared_ptr<Expression>(new ArrayExpression(expressions));
}

// ParenthesisOpenToken

ParenthesisOpenToken::ParenthesisOpenToken(Parser* parser_): Token(parser_, "(", 90)
{
}

shared_ptr<Expression> ParenthesisOpenToken::nud()
{
    shared_ptr<Expression> expression = parser->expression(5);
    parser->advance(")");
    return expression;
}

shared_ptr<Expression> ParenthesisOpenToken::led(shared_ptr<Expression> left)
{
    parser->setError("Unexpected (");
    return shared_ptr<Expression>(new BottomExpression());
}

IntervalOperatorToken::IntervalOperatorToken(
    Parser* parser_,
    string equalityOp_,
    string startOp_,
    string endOp_,
    Value minValue_,
    Value maxValue_
) : Token(parser_, "(interval)", 50) {
    equalityOp = equalityOp_;
    startOp = startOp_;
    endOp = endOp_;
    minValue = minValue_;
    maxValue = maxValue_;
}

shared_ptr<Expression> IntervalOperatorToken::led(shared_ptr<Expression> left)
{
    return shared_ptr<Expression>(new IntervalOperatorExpression(
        equalityOp,
        startOp,
        endOp,
        left,
        minValue,
        maxValue
    ));
}