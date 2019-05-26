#include "Expression.hpp"
#include "Parser.hpp"
#include "Token.hpp"
#include "Value.hpp"

using namespace std;

shared_ptr<Token> Parser::token()
{
    return cursor < tokens.size() ? tokens[cursor] : shared_ptr<Token>(new EndToken(this));
}

void Parser::advance()
{
    cursor++;
}

void Parser::advance(string type)
{
    advance(type, "Expected: " + type);
}

void Parser::advance(string type, string message)
{
    if (token()->type != type) {
        setError(message);
    }

    advance();
}

void Parser::setError(string error_)
{
    error = error_;
}

shared_ptr<Expression> Parser::expression(int rbp)
{
    if (error.size()) {
        return shared_ptr<Expression>(new BottomExpression());
    }

    shared_ptr<Expression> left;
    shared_ptr<Token> t = token();

    advance();
    left = t->nud();

    while (rbp < token()->lbp) {
        t = token();
        advance();
        left = t->led(left);
    }

    return left;
}

shared_ptr<Expression> Parser::parse(string text)
{
    cursor = 0;
    error = "";
    tokens = tokenizer.tokenize(this, text);

    if (tokenizer.error.size()) {
        setError(tokenizer.error);
        return shared_ptr<Expression>(new BottomExpression());
    }

    // cout << "tokens: ";
    // for (int i = 0; i < tokens.size(); i++) {
    //     cout << tokens[i]->type;
    // }
    // cout << endl;

    return expression(0);
}
