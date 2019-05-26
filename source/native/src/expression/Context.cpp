#include <Array.hpp>
#include "Context.hpp"
#include "Expression.hpp"

Value Context::get(string name)
{
    return Value();
}

void Context::assign(string name, Value value)
{
}

Value Context::call(string name, vector<shared_ptr<Expression>> arguments)
{
    return Value();
}

shared_ptr<Context> Context::redirect(string name)
{
    return NULL;
}

ObjectContext::ObjectContext(Variant object_)
{
    if (object_.get_type() != Variant::OBJECT) {
        cerr << "Invalid context" << endl;
        object = Object::_new();
        return;
    }

    object = Object::___get_from_variant(object_);
}

Value ObjectContext::get(string name)
{
    if (!object->has_method("get_context_variable")) {
        cerr << "context: godot object has no method get_context_variable" << endl;
        return Value();
    }

    Array godotArguments;
    godotArguments.push_back(name.c_str());
    Variant godotResult = object->callv("get_context_variable", godotArguments);

    return Value(godotResult);
}

void ObjectContext::assign(string name, Value value)
{
    if (!object->has_method("set_context_variable")) {
        cerr << "context: godot object has no method set_context_variable" << endl;
        return;
    }

    Array godotArguments;
    godotArguments.push_back(name.c_str());
    godotArguments.push_back(value);

    object->callv("set_context_variable", godotArguments);
}

shared_ptr<Context> ObjectContext::redirect(string name)
{
    if (!object->has_method("redirect_context")) {
        cerr << "context: godot object has no method redirect_context" << endl;
        return NULL;
    }

    Array godotArguments;
    godotArguments.push_back(name.c_str());
    Variant godotResult = object->callv("redirect_context", godotArguments);

    if (godotResult.get_type() == Variant::NIL) {
        return NULL;
    }

    return shared_ptr<Context>(new ObjectContext(godotResult));
}

Value ObjectContext::call(string name, vector<shared_ptr<Expression>> arguments)
{
    if ("cond" == name) {
        if (arguments.size() == 3) {
            Value cond = arguments[0]->evaluate(this);
            if  (cond.isBottom()) {
                return Value();
            }
            if (cond) {
                return arguments[1]->evaluate(this);
            }
            return arguments[2]->evaluate(this);
        }

        cerr << "context: invalid argument count for cond function: " << arguments.size() << endl;
        return Value();
    }

    if ("ifelse" == name) {
        if (arguments.size() == 3) {
            Value cond = arguments[0]->evaluate(this);
            Value trueValue = arguments[1]->evaluate(this);
            Value falseValue = arguments[2]->evaluate(this);
            if (cond.isBottom()) {
                return Value();
            }
            return cond ? trueValue : falseValue;
        }

        cerr << "context: invalid argument count for ifelse function: " << arguments.size() << endl;
        return Value();
    }

    if (!object->has_method("call_context_function")) {
        cerr << "context: godot object has no method call_context_function" << endl;
        return Value();
    }

    Array innerArguments;

    for (int i = 0; i < arguments.size(); i++) {
        innerArguments.push_back(arguments[i]->evaluate(this));
    }

    Array godotArguments;
    godotArguments.push_back(name.c_str());
    godotArguments.push_back(innerArguments);

    Variant godotResult = object->callv("call_context_function", godotArguments);

    return Value(godotResult);
}
