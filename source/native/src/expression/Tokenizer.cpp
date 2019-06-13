#include "Tokenizer.hpp"
#include "Token.hpp"
#include <string>
#include <algorithm>

#define IS_IDENTIFIER_CHAR(c) (isalpha(c) || '_' == c || '.' == c || isdigit(c))
#define MATCH_TOKEN_TYPE(v, e, t) (e < v.size() ? v[e]->type == t : false)
#define MATCH_COMPARATOR_TOKEN(v, e) (e < v.size() ? (v[e]->type == "=" || v[e]->type == "!=" || v[e]->type == "<" || v[e]->type == ">" || v[e]->type == "<=" || v[e]->type == ">=") : false)

vector<shared_ptr<Token>> Tokenizer::preprocess(Parser *parser, string text)
{
    int index_ = 0;
    bool isFloat = false;
    long long intValue = 0;
    string stringValue;
    int divisor = 0;
    string name;
    vector<shared_ptr<Token>> result;

    error = "";

    while (index_ < text.size() && error.size() == 0) {
        while (isspace(text[index_]))
            index_++;

        // Pseudo Strings (are stored as hash)
        if (text[index_] == '"') {
            stringValue = "";
            while (index_ < text.size()) {
                index_++;
                if (text[index_] == '"') {
                    break;
                }
                if (text[index_] == '\\') {
                    continue;
                }
                stringValue += text[index_];
            }
            index_++;
            result.push_back(shared_ptr<Token>(new LiteralToken(parser, Value(stringValue))));
            continue;
        }

        // Identifiers
        if (isalpha(text[index_])) {
            name = "";
            while (IS_IDENTIFIER_CHAR(text[index_])) {
                name = name + text[index_];
                index_++;
            }
            while (text[index_] == ' ') { // Handles variables like Pos X, Vel Y
                index_++;
            }
            if (IS_IDENTIFIER_CHAR(text[index_])) {
                name = name + "_";
            }
            while (IS_IDENTIFIER_CHAR(text[index_])) {
                name = name + text[index_];
                index_++;
            }
            std::transform(name.begin(), name.end(), name.begin(), ::tolower);
            result.push_back(shared_ptr<Token>(new IdentifierToken(parser, name)));
            continue;
        }

        switch (text[index_]) {
            case '.': case '0': case '1': case '2': case '3': case '4': case '5':
            case '6': case '7': case '8': case '9':
                intValue = 0;
                divisor = 1;
                isFloat = false;
                while (isdigit(text[index_]) || text[index_] == '.') {
                    if (text[index_] == '.' && !isFloat) {
                        isFloat = true;
                        index_++;
                        continue;
                    } else if (text[index_] == '.') {
                        error = "Invalid number notation";
                        index_++;
                        break;
                    }
                    intValue = intValue * 10 + (text[index_] - '0');
                    if (isFloat) {
                        divisor *= 10;
                    }
                    index_++;
                }
                if (isFloat) {
                    result.push_back(shared_ptr<Token>(new LiteralToken(parser, Value(((float) intValue / (float) divisor)))));
                } else {
                    result.push_back(shared_ptr<Token>(new LiteralToken(parser, Value((int) intValue))));
                }
                break;
            case '(':
                result.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
                index_++;
                break;
            case ')':
                result.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
                index_++;
                break;
            case ',':
                result.push_back(shared_ptr<Token>(new CommaToken(parser)));
                index_++;
                break;
            case '[':
                result.push_back(shared_ptr<Token>(new ReservedToken(parser, "[")));
                index_++;
                break;
            case ']':
                result.push_back(shared_ptr<Token>(new ReservedToken(parser, "]")));
                index_++;
                break;
            case '+':
                result.push_back(shared_ptr<Token>(new BinaryAndUnaryOperatorToken(parser, "+", 55, false)));
                index_++;
                break;
            case '-':
                result.push_back(shared_ptr<Token>(new BinaryAndUnaryOperatorToken(parser, "-", 55, false)));
                index_++;
                break;
            case '%':
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "%", 60, false)));
                index_++;
                break;
            case '/':
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "/", 60, false)));
                index_++;
                break;
            case '*':
                if (index_ + 1 < text.size() && text[index_ + 1] == '*') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "**", 65, true)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "*", 60, false)));
                index_++;
                break;
            case '^':
                if (index_ + 1 < text.size() && text[index_ + 1] == '^') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "^^", 15, false)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "^", 30, false)));
                index_++;
                break;
            case '&':
                if (index_ + 1 < text.size() && text[index_ + 1] == '&') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "&&", 20, false)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "&", 35, false)));
                index_++;
                break;
            case '|':
                if (index_ + 1 < text.size() && text[index_ + 1] == '|') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "||", 10, false)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "|", 25, false)));
                index_++;
                break;
            case '>':
                if (index_ + 1 < text.size() && text[index_ + 1] == '=') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, ">=", 50, false)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, ">", 50, false)));
                index_++;
                break;
            case '<':
                if (index_ + 1 < text.size() && text[index_ + 1] == '=') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "<=", 50, false)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "<", 50, false)));
                index_++;
                break;
            case ':':
                if (index_ + 1 < text.size() && text[index_ + 1] == '=') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, ":=", 40, false)));
                    break;
                }
                error = "Expected = after :";
                break;
            case '!':
                if (index_ + 1 < text.size() && text[index_ + 1] == '=') {
                    index_ += 2;
                    result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "!=", 45, false)));
                    break;
                }
                result.push_back(shared_ptr<Token>(new UnaryOperatorToken(parser, "!", 70)));
                index_++;
                break;
            case '=':
                result.push_back(shared_ptr<Token>(new BinaryOperatorToken(parser, "=", 45, false)));
                index_++;
                break;
            case '~':
                result.push_back(shared_ptr<Token>(new UnaryOperatorToken(parser, "~", 70)));
                index_++;
                break;
            default:
                error = "Invalid character: " + string(1, text[index_]);
                break;
        }
    }

    return result;
}

vector<shared_ptr<Token>> Tokenizer::postprocess(Parser *parser, vector<shared_ptr<Token>> oldtokens)
{
    vector<shared_ptr<Token>> newtokens;

    for (int i = 0; i < oldtokens.size(); i++) {
        bool isIntervalOperator = (MATCH_TOKEN_TYPE(oldtokens, i, "=") || MATCH_TOKEN_TYPE(oldtokens, i, "!="))
            && (MATCH_TOKEN_TYPE(oldtokens, i + 1, "(") || MATCH_TOKEN_TYPE(oldtokens, i + 1, "["))
            && MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)")
            && MATCH_TOKEN_TYPE(oldtokens, i + 3, ",")
            && MATCH_TOKEN_TYPE(oldtokens, i + 4, "(literal)")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 5, ")") || MATCH_TOKEN_TYPE(oldtokens, i + 5, "]"));

        if (isIntervalOperator) {
            newtokens.push_back(shared_ptr<Token>(new IntervalOperatorToken(
                parser,
                oldtokens[i]->type,
                oldtokens[i + 1]->type,
                oldtokens[i + 5]->type,
                dynamic_pointer_cast<LiteralToken>(oldtokens[i + 2])->value,
                dynamic_pointer_cast<LiteralToken>(oldtokens[i + 4])->value
            )));
            i += 5;
            continue;
        }

        /**
         * Special triggers
         *
         * Some triggers don't conform to the expression syntax, so we convert them to functions
         * so the context can implement the correct behavior
         *
         * Example:
         *
         * HitDefAttr = A, SA, HA
         *
         * This is a trigger that checks if the attr is in the list, result:
         *
         * HitDefAttr = A, SA, HA => HitDefAttr("A", "SA", "HA")
         */

        // Convert hitdeff expression to a function call

        bool isHitDefAttr = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "hitdefattr"
            && (MATCH_TOKEN_TYPE(oldtokens, i + 1, "=") || MATCH_TOKEN_TYPE(oldtokens, i + 1, "!="));

        if (isHitDefAttr) {
            newtokens.push_back(oldtokens[i]);
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(shared_ptr<Token>(new LiteralToken(parser, Value(oldtokens[i + 1]->type))));
            newtokens.push_back(shared_ptr<Token>(new CommaToken(parser)));
            i += 2;
            while (MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")) {
                newtokens.push_back(oldtokens[i]);

                if (MATCH_TOKEN_TYPE(oldtokens, i + 1, ",")) {
                    newtokens.push_back(shared_ptr<Token>(new CommaToken(parser)));
                    i += 2;
                    continue;
                }

                i += 1;
                break;
            }
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            continue;
        }

        /**
         * THe command trigger is converted to a function in format command("=", "name"), so the
         * implementation can do any type of logic:
         *
         * command = "a" => command("=", "a")
         */

        bool isCommand = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "command"
            && (MATCH_TOKEN_TYPE(oldtokens, i + 1, "=") || MATCH_TOKEN_TYPE(oldtokens, i + 1, "!="))
            && MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)");

        if (isCommand) {
            newtokens.push_back(oldtokens[i]);
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(shared_ptr<Token>(new LiteralToken(parser, Value(oldtokens[i + 1]->type))));
            newtokens.push_back(shared_ptr<Token>(new CommaToken(parser)));
            newtokens.push_back(oldtokens[i + 2]);
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            i+= 2;
            continue;
        }

        /**
         * The animelem trigger is converted to animelemtime:
         *
         * animelem = 1 => animelemtime(1) = 0
         * animelem = 1, >= 2 => animelemtime(1) >= 2
         * animelem = 1, -1 => animelemtime(1) = -1
         *
         * TODO: Refactor this ugly code
         */
        bool isAnimElemFormat30 = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "animelem"
            && MATCH_TOKEN_TYPE(oldtokens, i + 1, "=")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 2, "(identifier)"))
            && MATCH_TOKEN_TYPE(oldtokens, i + 3, ",")
            && MATCH_COMPARATOR_TOKEN(oldtokens, i + 4)
            && (MATCH_TOKEN_TYPE(oldtokens, i + 5, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 5, "(identifier)"));

        if (isAnimElemFormat30) {
            newtokens.push_back(shared_ptr<Token>(new IdentifierToken(parser, "animelemtime")));
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(oldtokens[i + 2]);
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            newtokens.push_back(oldtokens[i + 4]);
            newtokens.push_back(oldtokens[i + 5]);
            i+= 5;
            continue;
        }

        bool isAnimElemFormat20 = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "animelem"
            && MATCH_TOKEN_TYPE(oldtokens, i + 1, "=")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 2, "(identifier)"))
            && MATCH_TOKEN_TYPE(oldtokens, i + 3, ",")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 4, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 5, "(identifier)"));

        if (isAnimElemFormat20) {
            newtokens.push_back(shared_ptr<Token>(new IdentifierToken(parser, "animelemtime")));
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(oldtokens[i + 2]);
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            newtokens.push_back(oldtokens[i + 1]);
            newtokens.push_back(oldtokens[i + 4]);
            i+= 4;
            continue;
        }

        bool isAnimElemFormat31 = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "animelem"
            && MATCH_TOKEN_TYPE(oldtokens, i + 1, "=")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 2, "(identifier)"))
            && MATCH_TOKEN_TYPE(oldtokens, i + 3, ",")
            && MATCH_COMPARATOR_TOKEN(oldtokens, i + 4)
            && MATCH_TOKEN_TYPE(oldtokens, i + 5, "-")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 6, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 6, "(identifier)"));

        if (isAnimElemFormat31) {
            newtokens.push_back(shared_ptr<Token>(new IdentifierToken(parser, "animelemtime")));
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(oldtokens[i + 2]);
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            newtokens.push_back(oldtokens[i + 4]);
            newtokens.push_back(oldtokens[i + 5]);
            newtokens.push_back(oldtokens[i + 6]);
            i+= 6;
            continue;
        }

        bool isAnimElemFormat21 = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "animelem"
            && MATCH_TOKEN_TYPE(oldtokens, i + 1, "=")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 2, "(identifier)"))
            && MATCH_TOKEN_TYPE(oldtokens, i + 3, ",")
            && MATCH_TOKEN_TYPE(oldtokens, i + 4, "-")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 5, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 5, "(identifier)"));

        if (isAnimElemFormat21) {
            newtokens.push_back(shared_ptr<Token>(new IdentifierToken(parser, "animelemtime")));
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(oldtokens[i + 2]);
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            newtokens.push_back(oldtokens[i + 1]);
            newtokens.push_back(oldtokens[i + 4]);
            newtokens.push_back(oldtokens[i + 5]);
            i+= 5;
            continue;
        }

        bool isAnimElemFormat1 = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "animelem"
            && MATCH_TOKEN_TYPE(oldtokens, i + 1, "=")
            && (MATCH_TOKEN_TYPE(oldtokens, i + 2, "(literal)") || MATCH_TOKEN_TYPE(oldtokens, i + 2, "(identifier)"));

        if (isAnimElemFormat1) {
            newtokens.push_back(shared_ptr<Token>(new IdentifierToken(parser, "animelemtime")));
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(oldtokens[i + 2]);
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            newtokens.push_back(oldtokens[i + 1]);
            newtokens.push_back(shared_ptr<Token>(new LiteralToken(parser, Value(0))));
            i+= 2;
            continue;
        }

        /**
         * The const function transform the argument in a string if its a indentifier:
         * const(velocity.x) => const("velocity.x")
         */

        bool isConst = MATCH_TOKEN_TYPE(oldtokens, i, "(identifier)")
            && dynamic_pointer_cast<IdentifierToken>(oldtokens[i])->name == "const"
            && MATCH_TOKEN_TYPE(oldtokens, i + 1, "(")
            && MATCH_TOKEN_TYPE(oldtokens, i + 2, "(identifier)")
            && MATCH_TOKEN_TYPE(oldtokens, i + 3, ")");

        if (isConst) {
            newtokens.push_back(oldtokens[i]);
            newtokens.push_back(shared_ptr<Token>(new ParenthesisOpenToken(parser)));
            newtokens.push_back(shared_ptr<Token>(new LiteralToken(parser, Value(dynamic_pointer_cast<IdentifierToken>(oldtokens[i + 2])->name))));
            newtokens.push_back(shared_ptr<Token>(new ReservedToken(parser, ")")));
            i += 3;
            continue;
        }

        newtokens.push_back(oldtokens[i]);
    }

    return newtokens;
}

vector<shared_ptr<Token>> Tokenizer::tokenize(Parser *parser, string text)
{
    return postprocess(parser, preprocess(parser, text));
}
