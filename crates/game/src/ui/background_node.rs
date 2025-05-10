use godot::{classes::Texture2D, prelude::*};
use crate::{adapters::BackgroundAdapter, GameManager};
use mugen_data::background::{background::Background, static_background::StaticBackground};

#[derive(GodotClass)]
#[class(init, base=Node2D)]
pub struct BackgroundNode {
    base: Base<Node2D>,

    #[var(get, set)]
    pub background: Option<Gd<BackgroundAdapter>>,

    pub renderer: BackgroundRenderer,
}

#[godot_api]
impl INode2D for BackgroundNode {
    fn enter_tree(&mut self) {
        godot_print!("BackgroundNode::enter_tree");
    }
}

#[godot_api]
impl BackgroundNode {
    #[func]
    pub fn from_background(background: Gd<BackgroundAdapter>) -> Gd<Self> {
        Gd::from_init_fn(|base| {
            Self {
                background: Some(background),
                base,
                renderer: Default::default(),
            }
        })
    }
}

struct StaticBackgroundRendererData {
    static_background: StaticBackground,
   // texture: Gd<Texture2D>,
}

enum BackgroundRenderer {
    None,
    Static(StaticBackgroundRendererData),
}

impl Default for BackgroundRenderer {
    fn default() -> Self {
        Self::None
    }
}

impl From<Gd<BackgroundAdapter>> for BackgroundRenderer {
    fn from(adapter: Gd<BackgroundAdapter>) -> Self {
        let background = &adapter.bind().inner;
        let game_manager_singleton = GameManager::singleton();
        let game_manager = game_manager_singleton.bind();
        let core_assets = game_manager.core_assets.bind();
        let sprite_cache = game_manager.sprite_cache.bind();
        let sprite_file_path = &core_assets.motif_sprite_file_path;

        match background {
            Background::Static(static_background) => {
                // let sprite_handle = sprite_cache.get_sprite_handle(sprite_file_path, static_background.spriteid);

                Self::Static(StaticBackgroundRendererData {
                    static_background: static_background.clone(),
                    // texture: sprite_handle
                })
            },
            _ => Self::None,
        }
    }
}
