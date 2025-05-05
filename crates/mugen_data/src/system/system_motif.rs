use std::{collections::HashMap, io::{Error, ErrorKind}};

use glam::Vec2;

use crate::{animation::animations::Animations, text::text_file::TextFile};

use super::title_screen::TitleScreen;

#[derive(Default, Debug, Clone)]
pub struct SystemMotif {
    pub motif_name: String,
    pub motif_author: String,
    pub localcoord: Vec2,
    pub fonts: HashMap<usize, String>,
    pub sound_path: String,
    pub sprite_path: String,
    pub animations: Animations,
    pub title_screen: TitleScreen,
}

impl SystemMotif {
    pub fn from_text_file(text_file: &TextFile) -> Result<Self, Error> {
        let info = text_file.get_section("info")?;
        let files = text_file.get_section("files")?;
    
        let motif_name = info.get_attribute_or_default::<String>("name");
        let motif_author = info.get_attribute_or_default::<String>("author");
        let localcoord = info.get_attribute_or_default::<Vec2>("localcoord");
        let mut fonts = HashMap::<usize, String>::new();
    
        for i in 1..32 as usize {
            if let Some(path) = files.get_attribute::<String>(&format!("font{}", i)) {
                fonts.insert(i, path.clone());
            }
        }

        let sound_path = 
            files.get_attribute::<String>("snd")
                    .ok_or_else(|| Error::new(ErrorKind::InvalidData, "Missing files snd attribute"))?;

        let sprite_path = 
            files.get_attribute::<String>("spr")
                    .ok_or_else(|| Error::new(ErrorKind::InvalidData, "Missing files snd attribute"))?;

        Ok(Self {
            motif_name,
            motif_author,
            localcoord,
            fonts,
            sound_path,
            sprite_path,
            animations: Animations::from_text_file(&text_file)?,
            title_screen: TitleScreen::parse(&text_file)?,
        })
    }
}
