use std::{collections::HashMap, io::{Error, ErrorKind}};

use thunderdome::{Arena, Index};

use crate::io::reader::DataReader;

use super::{sff::{image::{Image, Palette}, sff_common::SffData, sffv1, sffv2}, sprite_id::SpriteId};

#[derive(Debug)]
pub struct SpriteFile {
    palette_storage: Arena<Palette>,

    image_storage: Arena<Image>,

    sprites: HashMap<SpriteId, SffData>,

    /**
     * Only SFFv2 supports palettes in the SFF file.
     */
    pub palettes: Vec<Index>,
}

#[derive(Clone, Debug)]
pub struct SpriteData {
    pub sff_data: SffData,
    pub image: Image,
}

impl Default for SpriteFile {
    fn default() -> Self {
        Self {
            palette_storage: Arena::new(),
            image_storage: Arena::new(),
            sprites: HashMap::new(),
            palettes: vec![],
        }
    }
}

impl SpriteFile {
    pub fn from_reader(reader: &mut dyn DataReader) -> Result<Self, Error> {
        let mut image_storage = Arena::new();
        let mut palette_storage = Arena::new();

        let mut sprites_result = sffv2::read_images(
            reader,
            &[],
            &mut image_storage,
            &mut palette_storage,
        );
        let mut should_read_palettes = true;

        if sprites_result.is_err() {
            // SFFv1 does not support palettes in the SFF file.
            should_read_palettes = false;
            reader.seek(0usize);
            sprites_result = sffv1::read_images(
                reader,
                &[],
                &mut image_storage,
                &mut palette_storage
            );
        }

        let mut palettes: Vec<Index> = vec![];

        if should_read_palettes {
            reader.seek(0);
            palettes = sffv2::read_palettes(reader, &mut palette_storage)?;
        }

        let sprites_list = sprites_result?;
        let sprites = sprites_list.into_iter().map(|s| (SpriteId::new(s.groupno, s.imageno), s)).collect();

        Ok(Self {
            palette_storage,
            image_storage,
            sprites,
            palettes
        })
    }

    pub fn has_palettes(&self) -> bool { self.palettes.len() > 0 }

    pub fn get_sff_data(&self, sprite_id: &SpriteId) -> Result<&SffData, Error> {
        let sff_data = self.sprites.get(sprite_id)
            .ok_or_else(|| Error::new(ErrorKind::InvalidData, format!("Image not found: {}", sprite_id)))?;

        Ok(sff_data)
    }

    pub fn get_sff_data_by_group(&self, groupno: i16) -> Result<Vec<&SffData>, Error> {
        let sffs = self.sprites.iter()
            .filter(|(id, _)| id.group == groupno)
            .map(|(_, sff)| sff)
            .collect();

        Ok(sffs)
    }

    pub fn get_sffv2_palette_by_number(&self, number: i16) -> Result<&Palette, Error> {
        let palette_index = self.palettes.get(number as usize)
            .ok_or_else(|| Error::new(ErrorKind::InvalidData, format!("Palette index not found: {}", number)))?;

        self.get_palette(*palette_index)
    }

    pub fn get_palette(&self, index: Index) -> Result<&Palette, Error> {
        self.palette_storage.get(index)
            .ok_or_else(|| Error::new(ErrorKind::InvalidData, format!("Palette not found in memory")))
    }

    pub fn get_image(&self, index: Index) -> Result<&Image, Error> {
        self.image_storage.get(index)
            .ok_or_else(|| Error::new(ErrorKind::InvalidData, format!("Image not found in memory")))
    }

    pub fn get_all_sff_data(&self) -> Vec<&SffData> {
        self.sprites.values().collect()
    }
}
