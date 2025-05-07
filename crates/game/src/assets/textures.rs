use godot::classes::Texture2D;
use mugen_data::{background::static_background::StaticBackground, sprite::sff::{image::Image, sff_common::SffData}};

pub struct BackgroundGroupTextures {
    pub backgrounds: Vec<BackgroundTextures>,
}

pub enum BackgroundTextures {
    None,
    Static(StaticBackgroundTextures),
}

pub struct StaticBackgroundTextures {
    pub texture: Texture2D,
    pub sff_data: SffData,
    pub image: Image,
    pub background: StaticBackground,
}
