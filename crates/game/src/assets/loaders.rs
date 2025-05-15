use std::collections::HashMap;

use anyhow::Result;
use godot::prelude::*;
use godot::builtin::GString;
use godot::classes::file_access::ModeFlags;
use godot::classes::{FileAccess, FontFile};
use mugen_data::sprite::{SpriteFile, FontFile as MugenFontFile};
use mugen_data::text::text_file::TextFile;
use crate::core::data::{GodotFileReader, GodotFilesystem};
use crate::helpers::map_io_error;

pub fn load_sprite_file(path: &str) -> Result<SpriteFile> {
    let file_option = FileAccess::open(&GString::from(path), ModeFlags::READ);
    let file = file_option.ok_or(anyhow::anyhow!("Sprite file does not exist: {}", path))?;
    let mut file_reader = GodotFileReader::new(file);
    SpriteFile::from_reader(&mut file_reader).map_err(
        map_io_error,
    )
}

pub fn load_text_file(path: &str) -> Result<TextFile> {
    let file_option = FileAccess::open(&GString::from(path), ModeFlags::READ);
    let file = file_option.ok_or(anyhow::anyhow!("Text file does not exist: {}", path))?;
    let mut file_reader = GodotFileReader::new(file);
    TextFile::from_reader(&mut file_reader).map_err(
        map_io_error,
    )
}

pub fn load_font(path: &str, font_directory: &str) -> Result<Gd<FontFile>> {
    let font_file = FontFile::new_gd();
    let filesystem = GodotFilesystem::new(font_directory);
    let mugen_font_file = MugenFontFile::build(&filesystem, path)?;

    Ok(font_file)
}

pub fn load_fonts(fonts: HashMap<usize, String>, font_directory: &str) -> Result<Array<Option<Gd<FontFile>>>> {
    let mut font_files = Array::new();
    let total_fonts = fonts.len() as usize;
    font_files.resize(total_fonts, None);
    for (slot, path) in fonts {
        if slot > total_fonts {
            return Err(anyhow::anyhow!("Font slot out of bounds: {}", slot));
        }
        let font_file = load_font(&path, font_directory)?;
        font_files.set(slot - 1, Some(&font_file));
    }
    Ok(font_files)
}
