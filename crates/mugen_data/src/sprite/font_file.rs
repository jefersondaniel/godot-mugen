use std::io::{Error, ErrorKind};

use thunderdome::{Arena, Index};

use crate::{font::{bitmap_font::BitmapFont, fnt_parser::read_fnt_v1, font::Font, font_container::FontContainer, properties::{FontSpacing, GlyphSpacing}, vector_font::VectorFont}, io::{file::FileReader, reader::DataReader}, text::text_file::TextFile, types::{Rect2, Vector2}};

use super::{sff::image::{Image, Palette}, sprite_file::SpriteFile};

fn load_mugen_font(
    reader: &mut dyn DataReader,
    path: &str,
    file_reader: &dyn FileReader,
    image_storage: &mut Arena<Image>,
    palette_storage: &mut Arena<Palette>,
) -> Result<FontContainer, Error> {
    if path.to_lowercase().ends_with(".fnt") {
        return load_font_v1(reader, image_storage, palette_storage);
    } else if path.to_lowercase().ends_with(".def") {
        return load_font_v2(reader, path, file_reader, image_storage);
    }

    Err(Error::new(ErrorKind::InvalidData, format!("Invalid font file: {}", path)))
}

fn load_font_v1(
    reader: &mut dyn DataReader,
    image_storage: &mut Arena<Image>,
    palette_storage: &mut Arena<Palette>,
) -> Result<FontContainer, Error> {
    let fnt_file = read_fnt_v1(reader, image_storage, palette_storage)?;

    let mut bitmap_font = BitmapFont::new(
        fnt_file.images,
        FontSpacing {
            line_gap: fnt_file.size.y + fnt_file.spacing.y,
            ..Default::default()
        }
    );

    for (character, char_data) in fnt_file.char_map.iter() {
        bitmap_font.add_character(
            *character,
            0,
            char_data.rect,
            Vector2::new(0.0, 0.0),
            GlyphSpacing {
                h_advance: char_data.rect.size.x + fnt_file.spacing.x,
                ..Default::default()
            }
        )
    }

    bitmap_font.add_character(
        ' ',
        0,
        Rect2::default(),
        Vector2::new(0.0, 0.0),
        GlyphSpacing {
            h_advance: fnt_file.size.x + fnt_file.spacing.x,
            ..Default::default()
        }
    );

    return Ok(FontContainer {
        font_banks: vec![Font::BitmapFont {
            font: bitmap_font,
        }],
        size: 0,
    })
}

fn load_font_v2(
    reader: &mut dyn DataReader,
    path: &str,
    file_reader: &dyn FileReader,
    image_storage: &mut Arena<Image>,
) -> Result<FontContainer, Error> {
    let text_file = TextFile::from_string(reader.get_as_text());
    let def_section = text_file.get_section("def")?;
    let filename: String = def_section.get_attribute_or_fail("file")?;
    let size: Vector2 = def_section.get_attribute_or_default("size");
    let spacing: Vector2 = def_section.get_attribute_or_default("spacing");
    let offset: Vector2 = def_section.get_attribute_or_default("offset");
    let font_path = file_reader.get_path_by_referrer(&filename, path);

    if font_path.to_lowercase().ends_with(".sff") {
        let base_bitmap_font = BitmapFont::new(
            vec![],
            FontSpacing {
                line_gap: size.y + spacing.y,
                ..Default::default()
            }
        );
        let mut sprite_reader = file_reader.read(&font_path)?;
        let sprite_file = SpriteFile::from_reader(sprite_reader.as_mut())?;
        let images = sprite_file.get_sff_data_by_group(0)?;
        let mut font_banks: Vec<Font> = Vec::new();

        for palette_index in sprite_file.palettes.iter() {
            let mut bitmap_font = base_bitmap_font.clone();
            let mut texture_id: usize = 0;
            for sff_item in images.iter() {
                let character = char::from_u32(sff_item.imageno as u32)
                    .ok_or(Error::new(ErrorKind::InvalidData, format!("Invalid char code: {}", sff_item.imageno)))?;
                let image = sprite_file.get_image(sff_item.image)?;
                let image_index = image_storage.insert(image.with_palette(*palette_index));
                bitmap_font.add_image(image_index);
                bitmap_font.add_character(
                    character,
                    texture_id,
                    Rect2::new(
                        Vector2::new(0.0, 0.0),
                        Vector2::new(image.width as f32, image.height as f32)
                    ),
                    Vector2::new(offset.x, offset.y - size.y),
                    GlyphSpacing {
                        h_advance: image.width as f32 + spacing.x,
                        ..Default::default()
                    }
                );
                texture_id += 1;
            }
            bitmap_font.add_character(
                ' ',
                0,
                Rect2::default(),
                Vector2::new(0.0, 0.0),
                GlyphSpacing {
                    h_advance: size.x + spacing.x,
                    ..Default::default()
                }
            );
            font_banks.push(Font::BitmapFont { font: bitmap_font });
        }

        return Ok(FontContainer {
            font_banks,
            size: 0,
        })
    }

    return Ok(FontContainer {
        font_banks: vec![Font::VectorFont { font: VectorFont::new(font_path) }],
        size: size.y as i32,
    })
}

pub struct FontFile {
    image_storage: Arena<Image>,
    palette_storage: Arena<Palette>,
    pub font: FontContainer,
}

impl FontFile {
    pub fn build(
        filesystem: &dyn FileReader,
        path: &str
    ) -> Result<FontFile, Error> {
        let mut image_storage = Arena::new();
        let mut palette_storage = Arena::new();
        let mut reader = filesystem.read(path)?;
        let font = load_mugen_font(
            &mut *reader,
            path,
            filesystem,
            &mut image_storage,
            &mut palette_storage
        )?;

        Ok(FontFile {
            image_storage,
            palette_storage,
            font,
        })
    }

    pub fn get_image(&self, index: Index) -> Option<&Image> {
        self.image_storage.get(index)
    }

    pub fn get_palette(&self, index: Index) -> Option<&Palette> {
        self.palette_storage.get(index)
    }
}
