use std::io::Error;

use enumflags2::make_bitflags;

use crate::{regex::{RegEx, RegExFlags}, text::text_file::TextFile, types::Color};

use super::background::Background;

#[derive(Clone, Debug, Default)]
pub struct BackgroundGroup {
    pub clearcolor: Color,
    pub backgrounds: Vec<Background>,
}

impl BackgroundGroup {
    pub fn from_prefixed_text_sections(
        textfile: &TextFile,
        prefix: &str,
    ) -> Result<Self, Error> {
        let pattern = format!("^{}BG (.*)$", prefix);
        let regex = RegEx::new(&pattern, make_bitflags!(RegExFlags::{IgnoreCase}));
        let mut backgrounds = Vec::new();

        for textsection in textfile.sections.iter() {
            if regex.is_match(&textsection.title) {
                backgrounds.push(Background::from_text_section(
                    textsection,
                )?);
            }
        }

        let bgdef = textfile.get_section(&format!("{}BGdef", prefix))?;
        let clearcolor = bgdef.get_attribute_or_default("bgclearcolor");

        Ok(BackgroundGroup {
            clearcolor,
            backgrounds,
        })
    }
}
