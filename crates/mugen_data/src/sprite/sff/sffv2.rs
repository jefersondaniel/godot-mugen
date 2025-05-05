use thunderdome::{Arena, Index};

use crate::io::reader::{BufferReader, DataReader};
use crate::types::Color;
use super::image::{Palette, Image};
use super::lz5::decode_lz5;
use super::rle5::{decode_rle5, decode_rle8};
use super::sff_common::{SffData, SffPal, SffMetadata};
use std::collections::HashMap;
use std::io::{Error,ErrorKind};

#[allow(dead_code)]
struct FileHeader {
    signature: String,
    verlo3: u8,
    verlo2: u8,
    verlo1: u8,
    verhi: u8,
    reserved1: Vec<u8>, // [u8, 4]
    reserved2: Vec<u8>, // [u8, 4]
    compatverlo3: u8,
    compatverlo2: u8,
    compatverlo1: u8,
    compatverhi: u8,
    reserved3: Vec<u8>, // [u8; 4]
    reserved4: Vec<u8>, // [u8; 4]
    first_sprnode_offset: u32,
    total_frames: u32,
    first_palnode_offset: u32,
    total_palettes: u32,
    ldata_offset: u32,
    ldata_length: u32,
    tdata_offset: u32,
    tdata_length: u32,
    reserved5: Vec<u8>, // [u8; 4]
    reserved6: Vec<u8>, // [u8; 4]
    unused: Vec<u8>,    // [u8; 436
}

impl FileHeader {
    fn read(reader: &mut dyn DataReader) -> FileHeader {
        FileHeader {
            signature: reader.get_text(12),
            verlo3: reader.get_u8(),
            verlo2: reader.get_u8(),
            verlo1: reader.get_u8(),
            verhi: reader.get_u8(),
            reserved1: reader.get_buffer(4),
            reserved2: reader.get_buffer(4),
            compatverlo3: reader.get_u8(),
            compatverlo2: reader.get_u8(),
            compatverlo1: reader.get_u8(),
            compatverhi: reader.get_u8(),
            reserved3: reader.get_buffer(4),
            reserved4: reader.get_buffer(4),
            first_sprnode_offset: reader.get_u32(),
            total_frames: reader.get_u32(),
            first_palnode_offset: reader.get_u32(),
            total_palettes: reader.get_u32(),
            ldata_offset: reader.get_u32(),
            ldata_length: reader.get_u32(),
            tdata_offset: reader.get_u32(),
            tdata_length: reader.get_u32(),
            reserved5: reader.get_buffer(4),
            reserved6: reader.get_buffer(4),
            unused: reader.get_buffer(436),
        }
    }
}

struct SpriteHeader {
    groupno: i16,
    imageno: i16,
    w: i16,
    h: i16,
    x: i16,
    y: i16,
    linked: i16,
    fmt: u8,
    colordepth: u8,
    offset: u32,
    len: u32,
    palindex: i16,
    flags: i16,
}

impl SpriteHeader {
    fn read(reader: &mut dyn DataReader) -> SpriteHeader {
        SpriteHeader {
            groupno: reader.get_i16(),
            imageno: reader.get_i16(),
            w: reader.get_i16(),
            h: reader.get_i16(),
            x: reader.get_i16(),
            y: reader.get_i16(),
            linked: reader.get_i16(),
            fmt: reader.get_u8(),
            colordepth: reader.get_u8(),
            offset: reader.get_u32(),
            len: reader.get_u32(),
            palindex: reader.get_i16(),
            flags: reader.get_i16(),
        }
    }
}

struct PaletteHeader {
    groupno: i16,
    itemno: i16,
    numcols: i16,
    linked: i16,
    offset: u32,
    len: u32,
}

impl PaletteHeader {
    fn read(reader: &mut dyn DataReader) -> PaletteHeader {
        PaletteHeader {
            groupno: reader.get_i16(),
            itemno: reader.get_i16(),
            numcols: reader.get_i16(),
            linked: reader.get_i16(),
            offset: reader.get_u32(),
            len: reader.get_u32(),
        }
    }
}

fn matrix_to_pal(reader: &mut dyn DataReader, size: usize) -> Palette {
    let mut colors: Vec<Color> = Vec::with_capacity(size);
    for i in 0..size {
        let r = reader.get_u8();
        let g = reader.get_u8();
        let b = reader.get_u8();
        reader.get_u8(); // TODO: Handle alpha channel
        colors.push(Color::new(r, g, b, if i == 0 { 0 } else { 255 }));
    }
    Palette::from_colors(colors)
}

fn open(reader: &mut dyn DataReader) -> Result<FileHeader, Error> {
   let head = FileHeader::read(reader);

    if head.signature != "ElecbyteSpr" {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!("Invalid signature: {}", head.signature))
        );
    }

    if head.verhi != 2 {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!(
                "Invalid version: {}.{}.{}.{}",
                head.verhi, head.verlo1, head.verlo2, head.verlo3
            )
        ));
    }

    Result::Ok(head)
}

pub fn read_metadata(reader: &mut dyn DataReader) -> Result<SffMetadata, Error> {
    let head = open(reader)?;

    Result::Ok(SffMetadata {
        verlo3: head.verlo3,
        verlo2: head.verlo2,
        verlo1: head.verlo1,
        verhi: head.verhi,
    })
}

pub fn read_palettes(
    reader: &mut dyn DataReader,
    palette_storage: &mut Arena<Palette>,
) -> Result<Vec<Index>, Error> {
    let head = open(reader)?;
    let mut result: Vec<Index> = Vec::with_capacity(head.total_palettes as usize);
    let mut palnode: Vec<PaletteHeader> = Vec::with_capacity(head.total_palettes as usize);

    reader.seek(head.first_palnode_offset as usize);

    for _ in 0..head.total_palettes {
        palnode.push(PaletteHeader::read(reader));
    }

    for palette in palnode.iter() {
        let pal: Index = match palette.len {
            0 => result[palette.linked as usize],
            len if len > 0 => {
                let mut offset: usize = head.ldata_offset as usize;
                offset += palette.offset as usize;
                reader.seek(offset as usize);

                let tmp_arr = reader.get_buffer((palette.numcols * 4) as usize);
                let mut tmp_arr_reader = BufferReader::new(tmp_arr);
                palette_storage.insert(matrix_to_pal(&mut tmp_arr_reader, palette.numcols as usize))
            }
            _ => Index::DANGLING
        };

        result.push(pal);
    }

    Result::Ok(result)
}

pub fn read_images(
    reader: &mut dyn DataReader,
    groups: &[i16],
    image_storage: &mut Arena<Image>,
    palette_storage: &mut Arena<Palette>,
) -> Result<Vec<SffData>, Error> {
    let head = open(reader)?;

    let mut sffdata: HashMap<i32, SffData> = HashMap::new();
    let mut paldata: Vec<SffPal> = Vec::with_capacity(head.total_palettes as usize);
    let mut sprnode: Vec<SpriteHeader> = Vec::with_capacity(head.total_frames as usize);
    let mut palnode: Vec<PaletteHeader> = Vec::with_capacity(head.total_palettes as usize);
    let mut requested_indexes: Vec<i32> = Vec::new();

    reader.seek(head.first_palnode_offset as usize);

    for _ in 0..head.total_palettes {
        palnode.push(PaletteHeader::read(reader));
    }

    reader.seek(head.first_sprnode_offset as usize);

    for counter in 0..head.total_frames {
        let spr = SpriteHeader::read(reader);

        if groups.contains(&spr.groupno) {
            requested_indexes.push(counter as i32);
            if spr.len == 0 {
                requested_indexes.push(spr.linked as i32);
            }
        }

        sprnode.push(spr);
    }

    for palette in palnode.iter() {
        let pal: Index = match palette.len {
            0 => paldata[palette.linked as usize].pal,
            len if len > 0 => {
                let mut offset: usize = head.ldata_offset as usize;
                offset += palette.offset as usize;
                reader.seek(offset as usize);

                let tmp_arr = reader.get_buffer((palette.numcols * 4) as usize);
                let mut tmp_arr_reader = BufferReader::new(tmp_arr);
                palette_storage.insert(matrix_to_pal(&mut tmp_arr_reader, palette.numcols as usize))
            }
            _ => Index::DANGLING
        };

        paldata.push(SffPal {
            pal,
            itemno: palette.itemno as i32,
            groupno: palette.groupno as i32,
            is_used: false,
            usedby: -1,
            reserved: 0,
        });
    }

    //reading images
    for (counter, sprite) in sprnode.iter().enumerate() {
        if !groups.is_empty() && !requested_indexes.contains(&(counter as i32)) {
            continue;
        }

        let linked;
        let mut image = Index::DANGLING;
        if sprite.len == 0 {
            linked = -1;
            image = sffdata[&(sprite.linked as i32)].image;
        } else {
            let mut offset: usize = 0;
            if sprite.flags == 0 {
                offset = head.ldata_offset as usize;
            }
            if sprite.flags != 0 {
                offset = head.tdata_offset as usize;
            }

            offset += sprite.offset as usize;
            reader.seek(offset as usize);

            let mut tmp_arr = reader.get_buffer(sprite.len as usize);
            let mut tmp_reader = BufferReader::new(tmp_arr.clone());

            match sprite.fmt {
                2 => tmp_arr = decode_rle8(&mut tmp_reader),
                3 => tmp_arr = decode_rle5(&mut tmp_reader),
                4 => tmp_arr = decode_lz5(&mut tmp_reader),
                _ => (),
            };

            let expected_size = (sprite.w as usize * sprite.h as usize) as usize;
            let actual_size = tmp_arr.len() as usize;

            if expected_size != actual_size {
                return Err(Error::new(
                    ErrorKind::InvalidData,
                    format!(
                        "Image decoding failed. GroupNo={}. ImageNo={}",
                        sprite.groupno, sprite.imageno
                    )
                ));
            }

            if sprite.colordepth == 5 || sprite.colordepth == 8 {
                image = image_storage.insert(Image::new(
                    sprite.w as usize,
                    sprite.h as usize,
                    tmp_arr,
                    paldata[sprite.palindex as usize].pal
                ));
            }

            linked = -1;
        }

        sffdata.insert(counter as i32, SffData {
            groupno: sprite.groupno,
            imageno: sprite.imageno,
            x: sprite.x,
            y: sprite.y,
            palindex: sprite.palindex,
            image,
            linked,
        });
    }

    for (a, item) in sffdata.iter_mut() {
        let b = item.palindex as usize;
        if !paldata[b].is_used {
            paldata[b].is_used = true;
            paldata[b].usedby = *a;
        }
    }

    Result::Ok(sffdata.into_values().collect())
}
