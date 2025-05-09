use godot::prelude::*;
use anyhow::Result;
use super::CoreAssets;
use crate::adapters::BackgroundGroupAdapter;

#[derive(GodotClass)]
#[class(init, base=RefCounted)]
pub struct TitleScreenData {
    #[var(get)]
    pub background_group: Gd<BackgroundGroupAdapter>,
}

impl TitleScreenData {
    pub fn build(core_assets: &CoreAssets) -> Result<TitleScreenData> {
        let background_group_adapter = BackgroundGroupAdapter::build(
            &core_assets.motif_sprite_file_path,
            &core_assets.motif.title_screen.background_group
        );

        Ok(Self { background_group: background_group_adapter })
    }
}
