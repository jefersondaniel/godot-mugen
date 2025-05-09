use std::collections::HashMap;

use anyhow::Result;
use godot::prelude::*;
use mugen_data::sprite::sprite_file::SpriteFile;
use mugen_data::sprite::sprite_id::SpriteId;
use mugen_data::sprite::sprite_file::SpriteData;
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

#[derive(GodotClass)]
#[class(init, base=RefCounted)]
pub struct SpriteCache {
    file_hash_cache: HashMap<String, u64>,
    file_cache: HashMap<u64, SpriteFile>,
}

impl SpriteCache {
    pub fn warmup_file(&mut self, path: &str) -> Result<()> {
        let sprite_file = load_sprite_file(&path)?;
        let file_hash = hash(&path);
        self.file_hash_cache.insert(String::from(path), file_hash);
        self.file_cache.insert(file_hash, sprite_file);
        Ok(())
    }

    pub fn forget_file(&mut self, path: String) {
        let hash = self.file_hash_cache.remove(&path);
        if let Some(hash) = hash {
            self.file_cache.remove(&hash);
        }
    }

    pub fn get_sprite_file(&self, path: String) -> Option<&SpriteFile> {
        self.file_hash_cache.get(&path).and_then(|hash| self.file_cache.get(hash))
    }

    pub fn get_sprite_handle(&self, path: String, sprite_id: SpriteId) -> SpriteHandle {
        SpriteHandle {
            file_hash: *self.file_hash_cache.get(&path).unwrap(),
            group: sprite_id.group,
            image: sprite_id.image,
        }
    }

    pub fn get_sprite_data(&self, handle: SpriteHandle) -> Option<SpriteData> {
        let sprite_file = self.get_sprite_file(handle.file_hash.to_string());
        if let Some(sprite_file) = sprite_file {
            let sff_data = sprite_file.get_sff_data(&SpriteId::new(handle.group, handle.image));
            if let Ok(sff_data) = sff_data {
                let image = sprite_file.get_image(sff_data.image);
                if let Ok(image) = image {
                    return Some(SpriteData {
                        sff_data: sff_data.clone(),
                        image: image.clone(),
                    });
                }
            }
        }

        None
    }
}

fn hash(s: &str) -> u64 {
    let mut hasher = FnvHasher::default();
    s.hash(&mut hasher);
    hasher.finish()
}

