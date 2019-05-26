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
};

class BottomExpression : public Expression {
public:
    Value value;
    BottomExpression();
    Value evaluate(Context* context) override;
};

class LiteralExpression : public Expression {
public:
    Value value;
    LiteralExpression(Value value);
    Value evaluate(Context* context) override;
};

class VariableExpression : public Expression {
public:
    string name;
    VariableExpression(string name);
    Value evaluate(Context* context) override;
};

class DynamicVariableExpression : public Expression {
public:
    string baseName;
    shared_ptr<Expression> argument;
    DynamicVariableExpression(string baseName, shared_ptr<Expression> argument);
    Value evaluate(Context* context) override;
    string getName(Context* context);
};

class FunctionCallExpression : public Expression {
public:
    string name;
    vector<shared_ptr<Expression>> arguments;
    FunctionCallExpression(string name, vector<shared_ptr<Expression>> arguments);
    Value evaluate(Context* context) override;
};

class BinaryOperatorExpression : public Expression {
public:
    string op;
    shared_ptr<Expression> left;
    shared_ptr<Expression> right;
    BinaryOperatorExpression(string op, shared_ptr<Expression> left, shared_ptr<Expression> right);
    Value evaluate(Context* context) override;
};

class UnaryOperatorExpression : public Expression {
public:
    string op;
    shared_ptr<Expression> right;
    UnaryOperatorExpression(string op, shared_ptr<Expression> right);
    Value evaluate(Context* context) override;
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
};

class RedirectionExpression : public Expression {
private:
    shared_ptr<Expression> left;
    shared_ptr<Expression> right;
public:
    RedirectionExpression(shared_ptr<Expression> left, shared_ptr<Expression> right);
    Value evaluate(Context* context) override;
};

class ListExpression : public Expression {
private:
    string op;
    shared_ptr<Expression> left;
    vector<shared_ptr<Expression>> values;
public:
    ListExpression(string op, shared_ptr<Expression> left, vector<shared_ptr<Expression>> values);
    Value evaluate(Context* context) override;
};

#endif
