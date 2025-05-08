use godot::prelude::*;
use anyhow::Result;
use super::{BackgroundGroupTextures, CoreAssets};

pub struct TitleScreenData {
    pub textures: BackgroundGroupTextures,
}

impl TitleScreenData {
    pub fn build(core_assets: Gd<CoreAssets>) -> Result<TitleScreenData> {
        let core_assets_bind = &core_assets.bind();
        let background_group = &core_assets_bind.motif.title_screen.background_group;

        // let background_results: Vec<Result<BackgroundTextures, std::io::Error>> = background_group.backgrounds.iter().map(|background| {
        //     match background {
        //         Background::Static(static_background) => {
        //             let sprite = sprite_file.get_sprite(&static_background.spriteid)?;
        //             let palette = sprite_file.get_palette(sprite.palindex)?;
        //             let image = sprite_file.get_image(sprite.image)?;

        //             let texture = build_texture_with_palette(&image, &palette);

        //             Ok(BackgroundTextures::Static(StaticBackgroundTextures {
        //                 texture,
        //                 sff_data: sprite.clone(),
        //                 background: static_background.clone(),
        //                 image: image.clone(),
        //             }))
        //         },
        //         _ => Ok(BackgroundTextures::None),
        //     }
        // }).collect();

        // let mut backgrounds = Vec::with_capacity(background_results.len());

        // for result in background_results {
        //     match result {
        //         Ok(background_texture) => {
        //             backgrounds.push(background_texture);
        //         },
        //         Err(err) => {
        //             return Err(map_io_error(err));
        //         },
        //     }
        // }

        // Ok(Self {
        //     textures: BackgroundGroupTextures {
        //         backgrounds,
        //     },
        // })
        Err(anyhow::anyhow!("Not implemented"))
    }
}
