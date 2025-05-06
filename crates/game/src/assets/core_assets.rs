use anyhow::Result;
use mugen_data::{sprite::sprite_file::SpriteFile, system::{configuration::Configuration, system_motif::SystemMotif}};

use crate::helpers::{get_directory, join_paths, map_io_error};

use super::loaders::{load_sprite_file, load_text_file};

pub struct CoreAssets {
    pub directory: String,
    pub configuration: Configuration,
    pub motif: SystemMotif,
    pub motif_path: String,
    pub motif_sprite_file: SpriteFile,
}

impl CoreAssets {
    pub fn load(directory: &str) -> Result<CoreAssets> {
        // Configuration
        let configuration_path = join_paths(&[directory, "data/mugen.cfg"]);
        let configuration_text_file = load_text_file(&configuration_path)?;
        let configuration = Configuration::from_text_file(&configuration_text_file).map_err(
            map_io_error,
        )?;

        // Motif
        let motif_path = join_paths(&[directory, &configuration.options.motif_path]);
        let motif_text_file = load_text_file(&motif_path)?;
        let motif = SystemMotif::from_text_file(&motif_text_file).map_err(
            map_io_error,
        )?;
        let motif_sprite_file_path = join_paths(&[&get_directory(&motif_path), &motif.sprite_path]);
        let motif_sprite_file = load_sprite_file(&motif_sprite_file_path)?;

        Ok(CoreAssets {
            directory: directory.to_string(),
            configuration,
            motif,
            motif_path,
            motif_sprite_file,
        })
    }
}
