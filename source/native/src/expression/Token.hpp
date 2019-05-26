#ifndef TOKEN_HPP
#define TOKEN_HPP

#include <iostream>
#include <memory>
#include "Parser.hpp"
#include "Value.hpp"

using namespace std;

class Token {
protected:
    Parser* parser;
public:
    int lbp;
    string type;
    Token(Parser* parser, string type, int lbp);
    virtual shared_ptr<Expression> nud();
    virtual shared_ptr<Expression> led(shared_ptr<Expression> left);
};

class LiteralToken : public Token {
public:
    Value value;
    LiteralToken(Parser* parser, Value value);
    shared_ptr<Expression> nud() override;
};

class IdentifierToken : public Token {
public:
    string name;
    IdentifierToken(Parser* parser, string name);
    shared_ptr<Expression> nud() override;
};

class BinaryAndUnaryOperatorToken : public Token {
public:
    string op;
    int precedence;
    bool rightAssociative;
    BinaryAndUnaryOperatorToken(Parser* parser, string op, int precedence, bool rightAssociative);
    shared_ptr<Expression> led(shared_ptr<Expression> left) override;
    shared_ptr<Expression> nud() override;
};

class BinaryOperatorToken : public Token {
public:
    string op;
    int precedence;
    bool rightAssociative;
    BinaryOperatorToken(Parser* parser, string op, int precedence, bool rightAssociative);
    shared_ptr<Expression> led(shared_ptr<Expression> left) override;
};

class UnaryOperatorToken : public Token {
public:
    string op;
    int precedence;
    UnaryOperatorToken(Parser* parser, string op, int precedence);
    shared_ptr<Expression> nud() override;
};

class ParenthesisOpenToken : public Token {
public:
    ParenthesisOpenToken(Parser* parser);
    shared_ptr<Expression> nud() override;
    shared_ptr<Expression> led(shared_ptr<Expression> left) override;
};

class ReservedToken : public Token {
public:
    ReservedToken(Parser* parser, string type);
    shared_ptr<Expression> nud() override;
    shared_ptr<Expression> led(shared_ptr<Expression> left) override;
};

class IntervalOperatorToken : public Token {
public:
    string equalityOp;
    string startOp;
    string endOp;
    Value minValue;
    Value maxValue;
    IntervalOperatorToken(Parser* parser, string equalityOp, string startOp, string endOp, Value minValue, Value maxValue);
    shared_ptr<Expression> led(shared_ptr<Expression> left) override;
};

class EndToken : public Token {
public:
    EndToken(Parser* parser);
};

#endif
