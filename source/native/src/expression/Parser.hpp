#ifndef PARSER_HPP
#define PARSER_HPP

#include <iostream>
#include <memory>
#include <vector>
#include "Tokenizer.hpp"

class Expression;
class Token;

using namespace std;

/**
 * Top down expression parser
 *
 * Implement ideas from http://effbot.org/zone/simple-top-down-parsing.htm
 */
class Parser {
private:
    int cursor;
    Tokenizer tokenizer;
    vector<shared_ptr<Token>> tokens;
public:
    string error;
    void advance();
    void advance(string name);
    void advance(string name, string message);
    shared_ptr<Token> token();
    shared_ptr<Expression> expression(int rbp);
    shared_ptr<Expression> parse(string text);
    void setError(string error);

};

#endif
