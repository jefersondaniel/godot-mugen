use anyhow::Result;
use godot::builtin::GString;
use godot::classes::file_access::ModeFlags;
use godot::classes::FileAccess;
use mugen_data::sprite::sprite_file::SpriteFile;
use mugen_data::text::text_file::TextFile;
use crate::core::data::GodotFileReader;
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
