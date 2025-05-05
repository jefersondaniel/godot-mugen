use std::io::{ErrorKind, Error};
use std::fmt;

use enumflags2::make_bitflags;

use crate::{attribute_value::AttributeValue, io::reader::DataReader, regex::{RegEx, RegExFlags}, text::text_section::TextSection};

pub struct TextFile {
    pub sections: Vec<TextSection>
}

impl TextFile {
    pub fn new(sections: Vec<TextSection>) -> Self {
        TextFile {
          sections: sections
        }
    }

    pub fn get_section(&self, key: &str) -> Result<TextSection, Error> {
        for section in self.sections.iter() {
            if section.title.to_lowercase() == key.to_lowercase() {
                return Ok(section.clone())
            }
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Missing section: {}", key)))
    }

    pub fn from_string(text: String) -> Self {
        let titleregex = RegEx::new(r"^\s*\[(.+?)\]\s*$", make_bitflags!(RegExFlags::{IgnoreCase}));
        let parsedlineregex = RegEx::new(r"^\s*(.+?)\s*=\s*(.+?)\s*$", make_bitflags!(RegExFlags::{IgnoreCase}));
        let mut sections: Vec<TextSection> = Vec::new();
        let mut sectiontitle: String = "".to_string();
        let mut sectionlines: Vec<AttributeValue> = Vec::new();
        let mut sectionparsedlines: Vec<(String, AttributeValue)> = Vec::new();

        for raw_line in text.lines() {
            let mut line = raw_line.trim().to_string();

            if let Some(commentindex) = line.find(';') {
                line = line[..commentindex].to_string();
            }

            line = line.trim().to_string();

            if line.is_empty() {
                continue;
            }

            if let Some(title_match) = titleregex.search(&line) {
                if !sectiontitle.is_empty() {
                    sections.push(TextSection::new(
                        sectiontitle.clone(),
                        sectionlines.clone(),
                        sectionparsedlines.clone()
                    ));
                }

                sectiontitle = title_match.get_string(1).to_string();
                sectionlines = Vec::new();
                sectionparsedlines = Vec::new();
                continue;
            }

            if sectiontitle.is_empty() {
                continue;
            }

            sectionlines.push(AttributeValue::new(&line));

            if let Some(line_match) = parsedlineregex.search(&line) {
                let key = line_match.get_string(1).to_string();
                let value = line_match.get_string(2).to_string();

                sectionparsedlines.push((key, AttributeValue::new(&value)));
            }
        }

        if !sectiontitle.is_empty() {
            sections.push(TextSection::new(
                sectiontitle.clone(),
                sectionlines.clone(),
                sectionparsedlines.clone()
            ));
        }

        TextFile::new(sections)
    }

    pub fn from_reader(reader: &mut dyn DataReader) -> Result<Self, Error> {
        let text = reader.get_as_text();
        Ok(TextFile::from_string(text))
    }
}

impl fmt::Debug for TextFile {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for section in self.sections.iter() {
            writeln!(f, "[{}]", section.title)?;

            for line in section.lines.iter() {
                writeln!(f, "{}", line.to_string())?;
            }
        }

        Ok(())
    }
}
