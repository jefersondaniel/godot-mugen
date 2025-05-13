use std::collections::HashMap;

use anyhow::Result;
use godot::classes::image::Format;
use godot::classes::{Image, ImageTexture, Texture2DArray};
use godot::{classes::Texture2D, prelude::*};
use mugen_data::sprite::sff::image::{Image as SffImage, Palette};
use mugen_data::sprite::{sff::sff_common::SffData, sprite_file::SpriteFile};
use mugen_data::sprite::sprite_id::SpriteId;
use super::loaders::load_sprite_file;
use fnv::FnvHasher;
use std::hash::{Hash, Hasher};

#[derive(Copy, Clone, GodotClass)]
#[class(init, base=RefCounted)]
pub struct SpriteHandle {
    file_hash: u64,
    group: i16,
    image: i16,
}

#[derive(Clone, Debug)]
pub struct SpriteData {
    pub sff_data: SffData,
    pub image: SffImage,
    default_palette: Palette,
}

#[derive(Clone, GodotClass)]
#[class(init, base=RefCounted)]
pub struct TextureGroup {
    pub image: Gd<Image>,
    pub image_texture: Gd<ImageTexture>,
    pub palette_texture: Gd<ImageTexture>,
}

#[derive(GodotClass)]
#[class(init, base=RefCounted)]
pub struct SpriteCache {
    file_hash_cache: HashMap<String, u64>,
    file_hash_reverse_cache: HashMap<u64, String>,
    file_cache: HashMap<u64, SpriteFile>,
}

impl SpriteCache {
    pub fn warmup_file(&mut self, path: &str) -> Result<()> {
        let sprite_file = load_sprite_file(&path)?;
        let file_hash = hash(&path);
        self.file_hash_cache.insert(String::from(path), file_hash);
        self.file_hash_reverse_cache.insert(file_hash, String::from(path));
        self.file_cache.insert(file_hash, sprite_file);
        Ok(())
    }

    pub fn forget_file(&mut self, path: String) {
        let hash = self.file_hash_cache.remove(&path);
        if let Some(hash) = hash {
            self.file_hash_reverse_cache.remove(&hash);
            self.file_cache.remove(&hash);
        }
    }

    pub fn get_sprite_file(&self, handle: SpriteHandle) -> Option<&SpriteFile> {
        self.file_cache.get(&handle.file_hash)
    }

    pub fn get_sprite_handle(&self, path: &str, sprite_id: SpriteId) -> SpriteHandle {
        SpriteHandle {
            file_hash: *self.file_hash_cache.get(path).unwrap(),
            group: sprite_id.group,
            image: sprite_id.image,
        }
    }

    pub fn get_sprite_data(&self, handle: SpriteHandle) -> Option<SpriteData> {
        let sprite_file = self.get_sprite_file(handle);
        if let Some(sprite_file) = sprite_file {
            let sprite_id = SpriteId::new(handle.group, handle.image);
            let sff_data = sprite_file.get_sff_data(&sprite_id);
            if let Ok(sff_data) = sff_data {
                let image = sprite_file.get_image(sff_data.image);
                if let Ok(image) = image {
                    let palette = sprite_file.get_palette(image.palette).unwrap();

                    return Some(SpriteData {
                        sff_data: sff_data.clone(),
                        image: image.clone(),
                        default_palette: palette.clone(),
                    });
                }
            } else {
                godot_error!("Sprite not found: {}", &sprite_id);
            }
        } else {
            let fallback_filename = String::from("unknown");
            let filename = self.file_hash_reverse_cache.get(&handle.file_hash).unwrap_or(&fallback_filename);
            godot_error!("Sprite file not found: {}", filename);
        }

        None
    }

    fn create_palette_image(&self, palette: &Palette) -> Gd<Image> {
        let width = palette.colors.len();
        let mut byte_array = Vec::with_capacity(width * 4);
        for color in palette.colors.iter() {
            byte_array.push(color.r);
            byte_array.push(color.g);
            byte_array.push(color.b);
            byte_array.push(color.a);
        }
        let data = PackedByteArray::from(byte_array.as_slice());
        let mut image = Image::new_gd();

        image.set_data(
            width as i32,
            1 as i32,
            false,
            Format::RGBA8,
            &data,
        );

        image
    }

    fn create_sprite_image(&self, sprite_data: &SpriteData) -> Gd<Image> {
        let data = PackedByteArray::from(sprite_data.image.pixels.as_slice());
        let mut image = Image::new_gd();

        image.set_data(
            sprite_data.image.width as i32,
            sprite_data.image.height as i32,
            false,
            Format::R8,
            &data,
        );

        image
    }

    pub fn get_texture_group(&self, data: &SpriteData, palette: Option<&Palette>) -> TextureGroup {
        let image = self.create_sprite_image(&data);
        let palette_image = if let Some(palette) = palette {
            self.create_palette_image(palette)
        } else {
            self.create_palette_image(&data.default_palette)
        };
        let mut image_texture = ImageTexture::new_gd();
        image_texture.set_image(&image);
        let mut palette_texture = ImageTexture::new_gd();
        palette_texture.set_image(&palette_image);
        TextureGroup {
            image,
            image_texture,
            palette_texture,
        }
    }
}

fn hash(s: &str) -> u64 {
    let mut hasher = FnvHasher::default();
    s.hash(&mut hasher);
    hasher.finish()
}
