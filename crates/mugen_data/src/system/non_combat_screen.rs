use std::io::Error;

use crate::{background::background_group::BackgroundGroup, text::{text_file::TextFile, text_section::TextSection}};

#[derive(Clone, Debug, Default)]
pub struct NonCombatScreen {
    pub fadeintime: i32,
    pub fadeouttime: i32,
    pub background_group: BackgroundGroup,
}

impl NonCombatScreen {
    pub fn parse(
        textfile: &TextFile,
        section: &TextSection,
        prefix: &str,
    ) -> Result<Self, Error> {
        Ok(NonCombatScreen {
            fadeintime: section.get_attribute_or_default("fadein.time"),
            fadeouttime: section.get_attribute_or_default("fadeout.time"),
            background_group: BackgroundGroup::from_prefixed_text_sections(
                textfile,
                prefix,
            )?
        })
    }
}
