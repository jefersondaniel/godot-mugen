#ifndef EXPRESSION_HPP
#define EXPRESSION_HPP

#include <iostream>
#include <memory>
#include "Context.hpp"
#include "Value.hpp"

using namespace std;

class Expression {
public:
    string type;
    Expression(string type);
    virtual Value evaluate(Context* context);
    virtual string toString();
};

class BottomExpression : public Expression {
public:
    Value value;
    BottomExpression();
    Value evaluate(Context* context) override;
    string toString() override;
};

class LiteralExpression : public Expression {
public:
    Value value;
    LiteralExpression(Value value);
    Value evaluate(Context* context) override;
    string toString() override;
};

class VariableExpression : public Expression {
public:
    string name;
    VariableExpression(string name);
    Value evaluate(Context* context) override;
    string toString() override;
};

class DynamicVariableExpression : public Expression {
public:
    string baseName;
    shared_ptr<Expression> argument;
    DynamicVariableExpression(string baseName, shared_ptr<Expression> argument);
    Value evaluate(Context* context) override;
    string getName(Context* context);
    string toString() override;
};

class FunctionCallExpression : public Expression {
public:
    string name;
    vector<shared_ptr<Expression>> arguments;
    FunctionCallExpression(string name, vector<shared_ptr<Expression>> arguments);
    Value evaluate(Context* context) override;
    string toString() override;
};

class BinaryOperatorExpression : public Expression {
public:
    string op;
    shared_ptr<Expression> left;
    shared_ptr<Expression> right;
    BinaryOperatorExpression(string op, shared_ptr<Expression> left, shared_ptr<Expression> right);
    Value evaluate(Context* context) override;
    string toString() override;
};

class UnaryOperatorExpression : public Expression {
public:
    string op;
    shared_ptr<Expression> right;
    UnaryOperatorExpression(string op, shared_ptr<Expression> right);
    Value evaluate(Context* context) override;
    string toString() override;
};

class IntervalOperatorExpression : public Expression {
private:
    string op;
    string startOp;
    string endOp;
    shared_ptr<Expression> value;
    Value left;
    Value right;
public:
    IntervalOperatorExpression(
        string op,
        string startOp,
        string endOp,
        shared_ptr<Expression> value,
        Value left,
        Value right
    );
    Value evaluate(Context* context) override;
    string toString() override;
};

class RedirectionExpression : public Expression {
private:
    shared_ptr<Expression> left;
    shared_ptr<Expression> right;
public:
    RedirectionExpression(shared_ptr<Expression> left, shared_ptr<Expression> right);
    Value evaluate(Context* context) override;
    string toString() override;
};

class ArrayExpression : public Expression {
private:
    vector<shared_ptr<Expression>> expressions;
public:
    ArrayExpression(vector<shared_ptr<Expression>> expressions);
    Value evaluate(Context* context) override;
    string toString() override;
};

#endif
