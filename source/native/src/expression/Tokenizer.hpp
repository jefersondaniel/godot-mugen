#ifndef TOKENIZER_HPP
#define TOKENIZER_HPP

#include <iostream>
#include <memory>
#include <vector>

class Parser;
class Token;

using namespace std;

class Tokenizer {
private:
    vector<shared_ptr<Token>> preprocess(Parser *parser, string text);
    vector<shared_ptr<Token>> postprocess(Parser *parser, vector<shared_ptr<Token>> tokens);
public:
    string error;
    vector<shared_ptr<Token>> tokenize(Parser *parser, string text);
};

#endif
