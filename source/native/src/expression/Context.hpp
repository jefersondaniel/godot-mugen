#ifndef CONTEXT_HPP
#define CONTEXT_HPP

#include <iostream>
#include <vector>
#include <map>
#include <memory>
#include <Godot.hpp>
#include <Variant.hpp>
#include "Value.hpp"

using namespace std;
using namespace godot;

class Expression;

class Context {
public:
    virtual void assign(string name, Value value);
    virtual Value get(string name);
    virtual Value call(string name, vector<shared_ptr<Expression>> arguments);
    virtual shared_ptr<Context> redirect(string name);
};

class ObjectContext : public Context {
private:
    Object *object;
public:
    ObjectContext(Variant object);
    void assign(string name, Value value) override;
    Value get(string name) override;
    Value call(string name, vector<shared_ptr<Expression>> arguments) override;
    shared_ptr<Context> redirect(string name) override;
};

#endif
