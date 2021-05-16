use crate::expressions::token::Token;
use crate::expressions::value::Value;
use std::fmt;
use std::rc::Rc;

type Result<T> = std::result::Result<T, TokenizerError>;

#[derive(Debug, Clone)]
pub struct TokenizerError {
    message: String,
}

impl fmt::Display for TokenizerError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.message.to_string())
    }
}

fn is_identifier_char(text: char) -> bool {
    text.is_alphabetic() || text.is_numeric() || '_' == text || '.' == text
}

fn is_number_char(text: char) -> bool {
    text.is_numeric() || '.' == text
}

fn match_token_type(tokens: &[Rc<Token>], index: usize, type_name: &str) -> bool {
    if index < tokens.len() {
        tokens[index].get_type_name() == type_name
    } else {
        false
    }
}

fn match_comparator_token(tokens: &[Rc<Token>], index: usize) -> bool {
    if index < tokens.len() {
        let type_name = tokens[index].get_type_name();
        type_name == "="
            || type_name == "!="
            || type_name == "<"
            || type_name == ">"
            || type_name == "<="
            || type_name == ">="
    } else {
        false
    }
}

fn preprocess(text: String) -> Result<Vec<Rc<Token>>> {
    let mut is_float;
    let mut int_value;
    let mut string_value;
    let mut divisor;
    let mut name;
    let mut index: usize = 0;
    let mut result: Vec<Rc<Token>> = Vec::new();

    while index < text.len() {
        while index < text.len() && text[index..index + 1].trim().is_empty() {
            index += 1;
        }

        if index >= text.len() {
            break;
        }

        // Pseudo Strings (are stored as hash)
        if text[index..index + 1] == *"\"" {
            string_value = String::from("");
            while index < text.len() {
                index += 1;
                if text[index..index + 1] == *"\"" {
                    break;
                }
                if text[index..index + 1] == *"\\" {
                    continue;
                }
                string_value = vec![string_value, text[index..index + 1].to_string()].join("");
            }
            index += 1;
            result.push(Rc::new(Token::LiteralToken {
                value: Value::StringValue(string_value),
            }));
            continue;
        }

        // Identifiers
        if text
            .chars()
            .nth(index)
            .expect("Invalid text")
            .is_alphabetic()
        {
            name = String::from("");
            while index < text.len()
                && is_identifier_char(text.chars().nth(index).expect("Invalid text"))
            {
                name = vec![name, text[index..index + 1].to_string()].join("");
                index += 1;
            }
            while index < text.len() && text[index..index + 1] == *" " {
                // Handles variables like Pos X, Vel Y
                index += 1;
            }
            if index < text.len()
                && is_identifier_char(text.chars().nth(index).expect("Invalid text"))
            {
                name += "_";
            }
            while index < text.len()
                && is_identifier_char(text.chars().nth(index).expect("Invalid text"))
            {
                name = vec![name, text[index..index + 1].to_string()].join("");
                index += 1;
            }
            name = name.to_lowercase();
            result.push(Rc::new(Token::IdentifierToken { name }));
            continue;
        }

        match &text[index..index + 1] {
            "." | "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" => {
                int_value = 0;
                divisor = 1;
                is_float = false;
                while index < text.len()
                    && is_number_char(text.chars().nth(index).expect("Invalid text"))
                {
                    if &text[index..index + 1] == "." && !is_float {
                        is_float = true;
                        index += 1;
                        continue;
                    } else if &text[index..index + 1] == "." {
                        return Result::Err(TokenizerError {
                            message: String::from("Unexpected ."),
                        });
                    }
                    let text_int_value: i64 = (text
                        .chars()
                        .nth(index)
                        .expect("Invalid text")
                        .to_digit(10)
                        .unwrap())
                    .into();
                    int_value = int_value * 10 + text_int_value;
                    if is_float {
                        divisor *= 10;
                    }
                    index += 1;
                }
                if is_float {
                    result.push(Rc::new(Token::LiteralToken {
                        value: Value::FloatValue(int_value as f64 / divisor as f64),
                    }));
                } else {
                    result.push(Rc::new(Token::LiteralToken {
                        value: Value::IntValue(int_value),
                    }));
                }
            }
            "(" => {
                result.push(Rc::new(Token::ParenthesisOpenToken));
                index += 1;
            }
            ")" => {
                result.push(Rc::new(Token::ReservedToken {
                    name: ")".to_string(),
                }));
                index += 1;
            }
            "," => {
                result.push(Rc::new(Token::CommaToken));
                index += 1;
            }
            "[" => {
                result.push(Rc::new(Token::ReservedToken {
                    name: "[".to_string(),
                }));
                index += 1;
            }
            "]" => {
                result.push(Rc::new(Token::ReservedToken {
                    name: "]".to_string(),
                }));
                index += 1;
            }
            "+" => {
                result.push(Rc::new(Token::BinaryAndUnaryOperatorToken {
                    op: "+".to_string(),
                    precedence: 55,
                    right_associative: false,
                }));
                index += 1;
            }
            "-" => {
                result.push(Rc::new(Token::BinaryAndUnaryOperatorToken {
                    op: "-".to_string(),
                    precedence: 55,
                    right_associative: false,
                }));
                index += 1;
            }
            "%" => {
                result.push(Rc::new(Token::BinaryOperatorToken {
                    op: "%".to_string(),
                    precedence: 60,
                    right_associative: false,
                }));
                index += 1;
            }
            "/" => {
                result.push(Rc::new(Token::BinaryOperatorToken {
                    op: "/".to_string(),
                    precedence: 60,
                    right_associative: false,
                }));
                index += 1;
            }
            "*" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "*" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "**".to_string(),
                        precedence: 65,
                        right_associative: true,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "*".to_string(),
                        precedence: 60,
                        right_associative: false,
                    }));
                    index += 1;
                }
            }
            "^" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "^" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "^^".to_string(),
                        precedence: 15,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "^".to_string(),
                        precedence: 30,
                        right_associative: false,
                    }));
                    index += 1;
                }
            }
            "&" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "&" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "&&".to_string(),
                        precedence: 20,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "&".to_string(),
                        precedence: 35,
                        right_associative: false,
                    }));
                    index += 1;
                }
            }
            "|" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "|" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "||".to_string(),
                        precedence: 10,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "|".to_string(),
                        precedence: 25,
                        right_associative: false,
                    }));
                    index += 1;
                }
            }
            ">" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "=" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: ">=".to_string(),
                        precedence: 50,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: ">".to_string(),
                        precedence: 50,
                        right_associative: false,
                    }));
                    index += 1;
                }
            }
            "<" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "=" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "<=".to_string(),
                        precedence: 50,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "<".to_string(),
                        precedence: 50,
                        right_associative: false,
                    }));
                    index += 1;
                }
            }
            ":" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "=" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: ":=".to_string(),
                        precedence: 40,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    return Result::Err(TokenizerError {
                        message: String::from("Expected = after :"),
                    });
                }
            }
            "!" => {
                if index + 1 < text.len() && &text[(index + 1)..(index + 2)] == "=" {
                    result.push(Rc::new(Token::BinaryOperatorToken {
                        op: "!=".to_string(),
                        precedence: 45,
                        right_associative: false,
                    }));
                    index += 2;
                } else {
                    result.push(Rc::new(Token::UnaryOperatorToken {
                        op: "!".to_string(),
                        precedence: 70,
                    }));
                    index += 1;
                }
            }
            "=" => {
                result.push(Rc::new(Token::BinaryOperatorToken {
                    op: "=".to_string(),
                    precedence: 45,
                    right_associative: false,
                }));
                index += 1;
            }
            "~" => {
                result.push(Rc::new(Token::UnaryOperatorToken {
                    op: "~".to_string(),
                    precedence: 70,
                }));
                index += 1;
            }
            invalid_char => {
                return Result::Err(TokenizerError {
                    message: format!("Invalid character: \"{}\"", invalid_char),
                });
            }
        }
    }

    Result::Ok(result)
}

fn postprocess(oldtokens: Vec<Rc<Token>>) -> Vec<Rc<Token>> {
    let mut newtokens: Vec<Rc<Token>> = Vec::new();

    let mut i = 0;

    loop {
        if i >= oldtokens.len() {
            break;
        }

        let is_interval_operator = (match_token_type(&oldtokens, i, "=")
            || match_token_type(&oldtokens, i, "!="))
            && (match_token_type(&oldtokens, i + 1, "(")
                || match_token_type(&oldtokens, i + 1, "["))
            && match_token_type(&oldtokens, i + 2, "(literal)")
            && match_token_type(&oldtokens, i + 3, ",")
            && match_token_type(&oldtokens, i + 4, "(literal)")
            && (match_token_type(&oldtokens, i + 5, ")")
                || match_token_type(&oldtokens, i + 5, "]"));

        if is_interval_operator {
            newtokens.push(Rc::new(Token::IntervalOperatorToken {
                equality_op: oldtokens[i].get_type_name(),
                start_op: oldtokens[i + 1].get_type_name(),
                end_op: oldtokens[i + 5].get_type_name(),
                min_value: oldtokens[i + 2].get_literal_value(),
                max_value: oldtokens[i + 4].get_literal_value(),
            }));
            i += 6;
            continue;
        }

        // Special triggers
        //
        // Some triggers don't conform to the expression syntax, so we convert them to functions
        // so the context can implement the correct behavior
        //
        // Example:
        //
        // HitDefAttr = A, SA, HA
        //
        // This is a trigger that checks if the attr is in the list, result:
        //
        // HitDefAttr = A, SA, HA => HitDefAttr("=", "A", "SA", "HA")
        // HitDefAttr = , SA, HA => HitDefAttr("=", "SCA", "SA", "HA")

        // Convert hitdeff expression to a function call

        let is_hit_def_attr = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "hitdefattr"
            && (match_token_type(&oldtokens, i + 1, "=")
                || match_token_type(&oldtokens, i + 1, "!="));

        let sca = "sca";

        if is_hit_def_attr {
            newtokens.push(Rc::clone(&oldtokens[i]));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::new(Token::LiteralToken {
                value: Value::StringValue(oldtokens[i + 1].get_type_name()),
            }));
            newtokens.push(Rc::new(Token::CommaToken));
            i += 2;

            if match_token_type(&oldtokens, i, ",") {
                newtokens.push(Rc::new(Token::LiteralToken {
                    value: Value::StringValue(sca.to_string()),
                }));
                newtokens.push(Rc::new(Token::CommaToken));
                i += 1;
            }

            while match_token_type(&oldtokens, i, "(identifier)") {
                newtokens.push(Rc::clone(&oldtokens[i]));

                if match_token_type(&oldtokens, i + 1, ",") {
                    newtokens.push(Rc::new(Token::CommaToken));
                    i += 2;
                    continue;
                }

                i += 1;
                break;
            }
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            i += 1;
            continue;
        }

        // The command trigger is converted to a function in format command("=", "name"), so the
        // implementation can do any type of logic:
        //
        // command = "a" => command("=", "a")

        let is_command = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "command"
            && (match_token_type(&oldtokens, i + 1, "=")
                || match_token_type(&oldtokens, i + 1, "!="))
            && match_token_type(&oldtokens, i + 2, "(literal)");

        if is_command {
            newtokens.push(Rc::clone(&oldtokens[i]));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::new(Token::LiteralToken {
                value: Value::StringValue(oldtokens[i + 1].get_type_name()),
            }));
            newtokens.push(Rc::new(Token::CommaToken));
            newtokens.push(Rc::clone(&oldtokens[i + 2]));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            i += 3;
            continue;
        }

        // The animelem trigger is converted to animelemtime:
        //
        // animelem = 1 => animelemtime(1) = 0
        // animelem = 1, >= 2 => animelemtime(1) >= 2
        // animelem = 1, -1 => animelemtime(1) = -1
        //
        // TODO: Refactor this ugly code

        let is_anim_elem_format30 = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "animelem"
            && match_token_type(&oldtokens, i + 1, "=")
            && (match_token_type(&oldtokens, i + 2, "(literal)")
                || match_token_type(&oldtokens, i + 2, "(identifier)"))
            && match_token_type(&oldtokens, i + 3, ",")
            && match_comparator_token(&oldtokens, i + 4)
            && (match_token_type(&oldtokens, i + 5, "(literal)")
                || match_token_type(&oldtokens, i + 5, "(identifier)"));

        if is_anim_elem_format30 {
            newtokens.push(Rc::new(Token::IdentifierToken {
                name: "animelemtime".to_string(),
            }));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::clone(&oldtokens[i + 2]));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            newtokens.push(Rc::clone(&oldtokens[i + 4]));
            newtokens.push(Rc::clone(&oldtokens[i + 5]));
            i += 6;
            continue;
        }

        let is_anim_elem_format20 = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "animelem"
            && match_token_type(&oldtokens, i + 1, "=")
            && (match_token_type(&oldtokens, i + 2, "(literal)")
                || match_token_type(&oldtokens, i + 2, "(identifier)"))
            && match_token_type(&oldtokens, i + 3, ",")
            && (match_token_type(&oldtokens, i + 4, "(literal)")
                || match_token_type(&oldtokens, i + 5, "(identifier)"));

        if is_anim_elem_format20 {
            newtokens.push(Rc::new(Token::IdentifierToken {
                name: "animelemtime".to_string(),
            }));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::clone(&oldtokens[i + 2]));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            newtokens.push(Rc::clone(&oldtokens[i + 1]));
            newtokens.push(Rc::clone(&oldtokens[i + 4]));
            i += 5;
            continue;
        }

        let is_anim_elem_format31 = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "animelem"
            && match_token_type(&oldtokens, i + 1, "=")
            && (match_token_type(&oldtokens, i + 2, "(literal)")
                || match_token_type(&oldtokens, i + 2, "(identifier)"))
            && match_token_type(&oldtokens, i + 3, ",")
            && match_comparator_token(&oldtokens, i + 4)
            && match_token_type(&oldtokens, i + 5, "-")
            && (match_token_type(&oldtokens, i + 6, "(literal)")
                || match_token_type(&oldtokens, i + 6, "(identifier)"));

        if is_anim_elem_format31 {
            newtokens.push(Rc::new(Token::IdentifierToken {
                name: "animelemtime".to_string(),
            }));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::clone(&oldtokens[i + 2]));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            newtokens.push(Rc::clone(&oldtokens[i + 4]));
            newtokens.push(Rc::clone(&oldtokens[i + 5]));
            newtokens.push(Rc::clone(&oldtokens[i + 6]));
            i += 7;
            continue;
        }

        let is_anim_elem_format21 = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "animelem"
            && match_token_type(&oldtokens, i + 1, "=")
            && (match_token_type(&oldtokens, i + 2, "(literal)")
                || match_token_type(&oldtokens, i + 2, "(identifier)"))
            && match_token_type(&oldtokens, i + 3, ",")
            && match_token_type(&oldtokens, i + 4, "-")
            && (match_token_type(&oldtokens, i + 5, "(literal)")
                || match_token_type(&oldtokens, i + 5, "(identifier)"));

        if is_anim_elem_format21 {
            newtokens.push(Rc::new(Token::IdentifierToken {
                name: "animelemtime".to_string(),
            }));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::clone(&oldtokens[i + 2]));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            newtokens.push(Rc::clone(&oldtokens[i + 1]));
            newtokens.push(Rc::clone(&oldtokens[i + 4]));
            newtokens.push(Rc::clone(&oldtokens[i + 5]));
            i += 6;
            continue;
        }

        let is_anim_elem_format1 = match_token_type(&oldtokens, i, "(identifier)")
            && oldtokens[i].get_identifier_name() == "animelem"
            && match_token_type(&oldtokens, i + 1, "=")
            && (match_token_type(&oldtokens, i + 2, "(literal)")
                || match_token_type(&oldtokens, i + 2, "(identifier)"));

        if is_anim_elem_format1 {
            newtokens.push(Rc::new(Token::IdentifierToken {
                name: "animelemtime".to_string(),
            }));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::clone(&oldtokens[i + 2]));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            newtokens.push(Rc::clone(&oldtokens[i + 1]));
            newtokens.push(Rc::new(Token::LiteralToken {
                value: Value::IntValue(0),
            }));
            i += 3;
            continue;
        }

        // Transform the argument in a string if its a indentifier:
        // const(velocity.x) => const("velocity.x")
        // gethitvar(velocity.x) => gethitvar("velocity.x")

        let is_getter = match_token_type(&oldtokens, i, "(identifier)")
            && (oldtokens[i].get_identifier_name() == "const"
                || oldtokens[i].get_identifier_name() == "gethitvar")
            && match_token_type(&oldtokens, i + 1, "(")
            && match_token_type(&oldtokens, i + 2, "(identifier)")
            && match_token_type(&oldtokens, i + 3, ")");

        if is_getter {
            newtokens.push(Rc::clone(&oldtokens[i]));
            newtokens.push(Rc::new(Token::ParenthesisOpenToken));
            newtokens.push(Rc::new(Token::LiteralToken {
                value: Value::StringValue(oldtokens[i + 2].get_identifier_name()),
            }));
            newtokens.push(Rc::new(Token::ReservedToken {
                name: ")".to_string(),
            }));
            i += 4;
            continue;
        }

        newtokens.push(Rc::clone(&oldtokens[i]));

        i += 1;
    }

    newtokens
}

pub fn tokenize(text: String) -> Result<Vec<Rc<Token>>> {
    match preprocess(text) {
        Result::Ok(tokens) => Result::Ok(postprocess(tokens)),
        Result::Err(err) => Result::Err(err),
    }
}
