use std::io::Error;

use crate::text::text_file::TextFile;

#[derive(Clone, Debug, Default)]
pub struct ConfigurationOptions {
    pub difficulty: i32,
    pub life: i32,
    pub time: i32,
    pub game_speed: i32,
    pub team_1vs2_life: i32,
    pub team_lose_on_ko: i32,
    pub motif_path: String,
}

#[derive(Clone, Debug, Default)]
pub struct Configuration {
    pub options: ConfigurationOptions,
}

impl Configuration {
    pub fn from_text_file(text_file: &TextFile) -> Result<Self, Error> {
        let options_section = text_file.get_section("Options")?;
        let motif_path = options_section.get_attribute_or_fail::<String>("motif")?;

        let options = ConfigurationOptions {
            difficulty: options_section.get_attribute_or_fail::<i32>("Difficulty")?,
            life: options_section.get_attribute_or_fail::<i32>("Life")?,
            time: options_section.get_attribute_or_fail::<i32>("Time")?,
            game_speed: options_section.get_attribute_or_fail::<i32>("GameSpeed")?,
            team_1vs2_life: options_section.get_attribute_or_fail::<i32>("Team.1VS2Life")?,
            team_lose_on_ko: options_section.get_attribute_or_fail::<i32>("Team.LoseOnKO")?,
            motif_path: motif_path,
        };

        Ok(Self { options })
    }
}
