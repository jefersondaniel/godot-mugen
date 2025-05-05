use std::collections::HashMap;
use std::io::{ErrorKind, Error};

use thunderdome::{Arena, Index};

use crate::io::reader::{DataReader, BufferReader};
use crate::sprite::sff::image::{Image, Palette};
use crate::sprite::sff::pcx::read_pcx;
use crate::types::{Rect2, Vector2};
use crate::{attribute_value::{ParseAttributeValue, AttributeValue}, text::text_file::TextFile};

#[allow(dead_code)]
pub struct FileHeader {
    signature: String,
    verlo3: u8,
    verlo2: u8,
    verlo1: u8,
    verhi: u8,
    pcx_offset: u32,
    pcx_size: u32,
    text_offset: u32,
    text_size: u32,
    unused: Vec<u8>,
}

impl FileHeader {
    pub fn read(reader: &mut dyn DataReader) -> FileHeader {
        FileHeader {
            signature: reader.get_text(12),
            verlo3: reader.get_u8(),
            verlo2: reader.get_u8(),
            verlo1: reader.get_u8(),
            verhi: reader.get_u8(),
            pcx_offset: reader.get_u32(),
            pcx_size: reader.get_u32(),
            text_offset: reader.get_u32(),
            text_size: reader.get_u32(),
            unused: reader.get_buffer(40),
        }
    }
}

#[derive(Copy, Clone, PartialEq)]
pub enum FntType {
    Variable,
    Fixed
}

impl ParseAttributeValue for FntType {
    fn parse_attribute_value(value: AttributeValue) -> Result<FntType, Error> {
        let text = value.to_string().to_lowercase();

        if text.trim() == "variable" {
            return Ok(FntType::Variable);
        }

        Ok(FntType::Fixed)
    }
}

impl Default for FntType {
    fn default() -> Self { FntType::Fixed }
}

pub struct CharData {
    pub texture_index: usize,
    pub rect: Rect2,
}

pub struct FntFile {
    pub offset: Vector2,
    pub size: Vector2,
    pub spacing: Vector2,
    pub font_type: FntType,
    pub char_map: HashMap<char, CharData>,
    pub images: Vec<Index>,
}


pub fn read_fnt_v1(
    reader: &mut dyn DataReader,
    image_storage: &mut Arena<Image>,
    palette_storage: &mut Arena<Palette>,
) -> Result<FntFile, Error> {
    let head = FileHeader::read(reader);

    if head.signature != "ElecbyteFnt" {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!(
                "Fnt invalid signature: {}",
                head.signature
            ))
        );
    }

    reader.seek(head.text_offset as usize);
    let text = reader.get_text(head.text_size as usize);

    reader.seek(head.pcx_offset as usize);
    let pcx_arr = reader.get_buffer(head.pcx_size as usize);
    let mut pcx_arr_reader = BufferReader::new(pcx_arr);
    let image = image_storage.insert(read_pcx(&mut pcx_arr_reader, palette_storage)?);

    parse_fnt_file(
        &text, 
        image
    )
}

fn parse_fnt_file(
    text: &str,
    image: Index
) -> Result<FntFile, Error> {
    let text_file = TextFile::from_string(String::from(text));
    let def_section = text_file.get_section("def")?;
    let map_section = text_file.get_section("map")?;

    let offset: Vector2 = def_section.get_attribute_or_default("offset");
    let size: Vector2 = def_section.get_attribute_or_default("size");
    let spacing: Vector2 = def_section.get_attribute_or_default("spacing");
    let font_type: FntType = def_section.get_attribute_or_default("type");
    let mut char_map: HashMap<char, CharData> = HashMap::new();
    let images = vec![image];

    for (iterator, line) in map_section.lines.iter().enumerate() {
        let pieces = line.split_with_separator(' ', false);
        let character = parse_character(pieces[0].to_string())?;
        let mut char_start_x = iterator as f32 * size.x;
        // let mut char_width = size.x;

        if font_type == FntType::Variable {
            char_start_x = pieces[1].parse()
                .map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid char line: {}", line.to_string())))?;

            // TODO: Review char_width usage
            // char_width = pieces[2].parse()
            //    .map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid char line: {}", line.to_string())))?;
        }

        char_map.insert(character, CharData {
            texture_index: 0,
            rect: Rect2::new(
                Vector2::new(char_start_x, 0.0),
                size
            )
        });
    }

    Ok(FntFile {
        offset,
        size,
        spacing,
        font_type,
        char_map,
        images,
    })
}

fn parse_character(text: String) -> Result<char, Error> {
    if text.to_lowercase().starts_with("0x") {
        let num = u32::from_str_radix(
            text.to_lowercase().trim_start_matches("0x"),
            16
        ).map_err(
            |_| Error::new(ErrorKind::InvalidData, format!("Invalid char format: {}", text))
        )?;

        return char::from_u32(num)
            .ok_or(Error::new(ErrorKind::InvalidData, format!("Invalid char code: {}", text)))
    }

    text.chars().next()
        .ok_or(Error::new(ErrorKind::InvalidData, format!("Invalid char: {}", text)))
}
