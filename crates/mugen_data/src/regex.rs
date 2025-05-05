use std::fmt::Display;

use enumflags2::{bitflags, BitFlags};
use regex::{Captures, Regex, RegexBuilder};

pub struct RegEx {
    pattern: String,
    value: Option<Regex>
}

#[bitflags]
#[repr(u16)]
#[derive(Copy, Clone, PartialEq)]
pub enum RegExFlags {
    IgnoreCase = 1,
}

pub struct RegExMatch<'a> {
    captures: Captures<'a>,
}

impl Display for RegEx {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&self.pattern)
    }
}

impl RegEx {
    pub fn new(pattern: &str, flags: BitFlags<RegExFlags>) -> Self {
        let value = RegexBuilder::new(pattern)
            .case_insensitive(flags.contains(RegExFlags::IgnoreCase))
            .build()
            .ok();

        RegEx {
            pattern: pattern.to_string(),
            value: value
        }
    }

    pub fn search<'a>(&self, text: &'a str) -> Option<RegExMatch<'a>> {
        let value = self.value.as_ref()?;
        let captures = value.captures(&text)?;
        let regex_match: RegExMatch = RegExMatch { captures };

        Some(regex_match)
    }

    pub fn is_match<'a>(&self, text: &'a str) -> bool {
        if let Some(value) = self.value.as_ref() {
            return value.is_match(&text);
        }

        false
    }

    pub fn split<'a>(&self, text: &'a str) -> Option<Vec<&'a str>> {
        let value = self.value.as_ref()?;

        Some(value.split(text).collect())
    }
}

impl RegExMatch<'_> {
    pub fn get_string(&self, group: usize) -> String {
        self.captures.get(group).map_or("".to_string(), |m| m.as_str().to_string())
    }

    pub fn get_i32(&self, group: usize) -> Option<i32> {
        self.get_string(group).parse::<i32>().ok()
    }

    pub fn get_u8(&self, group: usize) -> Option<u8> {
        self.get_string(group).parse::<u8>().ok()
    }

    pub fn get_u16(&self, group: usize) -> Option<u16> {
        self.get_string(group).parse::<u16>().ok()
    }

    pub fn get_i16(&self, group: usize) -> Option<i16> {
        self.get_string(group).parse::<i16>().ok()
    }

    pub fn get_usize(&self, group: usize) -> Option<usize> {
        self.get_string(group).parse::<usize>().ok()
    }
}
