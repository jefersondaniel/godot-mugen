#ifndef MUGEN_EXPRESSION_H
#define MUGEN_EXPRESSION_H

#include <Godot.hpp>
#include <Reference.hpp>
#include "expression/Parser.hpp"
#include "expression/Expression.hpp"

using namespace godot;

class MugenExpression : public Reference {
    GODOT_CLASS(MugenExpression, Reference);
private:
    string error;
    shared_ptr<Expression> expression;
    static Parser parser;
public:
    void parse(String expression);
    Variant execute(Variant context);
    String get_error_text() const;
    bool has_error() const;
    String to_string() const;
    void _init();
    static void _register_methods();
};

#endif
