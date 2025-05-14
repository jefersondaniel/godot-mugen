use godot::prelude::*;
use mugen_data::background::{background_group::BackgroundGroup, background::Background};

#[derive(GodotClass)]
#[class(init, base=RefCounted)]
pub struct BackgroundAdapter {
    pub inner: Background,
    pub sprite_file_path: String,
}

impl BackgroundAdapter {
    fn build(value: &Background, sprite_file_path: &str) -> Gd<BackgroundAdapter> {
        let adapter = Self { inner: value.clone(), sprite_file_path: sprite_file_path.into() };
        Gd::from_object(adapter)
    }
}

#[derive(GodotClass)]
#[class(init, base=RefCounted)]
pub struct BackgroundGroupAdapter {
    pub inner: BackgroundGroup,

    #[var(get)]
    backgrounds: Array<Gd<BackgroundAdapter>>,

    #[var(get)]
    clearcolor: Color,
}

#[godot_api]
impl BackgroundGroupAdapter {
    #[func]
    pub fn get_clear_color(&self) -> Color {
        Color::from_rgba(
            (self.inner.clearcolor.r as f32 / 255.0) as f32,
            (self.inner.clearcolor.g as f32 / 255.0) as f32,
            (self.inner.clearcolor.b as f32 / 255.0) as f32,
            (self.inner.clearcolor.a as f32 / 255.0) as f32
        )
    }
}


impl BackgroundGroupAdapter {
    pub fn build(sprite_file_path: &str, inner: &BackgroundGroup) -> Gd<BackgroundGroupAdapter> {
       let clearcolor = Color::from_rgba(
            (inner.clearcolor.r as f32 / 255.0) as f32,
            (inner.clearcolor.g as f32 / 255.0) as f32,
            (inner.clearcolor.b as f32 / 255.0) as f32,
            (inner.clearcolor.a as f32 / 255.0) as f32
        );
        let mut backgrounds = Array::new();
        for background in inner.backgrounds.iter() {
            let background = BackgroundAdapter::build(background, sprite_file_path);
            backgrounds.push(&background);
        }
        let adapter = Self { inner: inner.clone(), backgrounds, clearcolor };
        Gd::from_object(adapter)
    }
}
