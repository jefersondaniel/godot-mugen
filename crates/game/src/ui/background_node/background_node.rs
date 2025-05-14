use godot::{classes::{IMeshInstance2D, MeshInstance2D}, prelude::*};
use crate::{adapters::BackgroundAdapter, GameManager};
use mugen_data::background::{background::Background};

use super::static_background::{configure_static_background, draw_static_background, process_static_background, StaticBackgroundRendererData};

#[derive(GodotClass)]
#[class(init, base=MeshInstance2D)]
pub struct BackgroundNode {
    base: Base<MeshInstance2D>,

    #[var(get, set)]
    pub background: Option<Gd<BackgroundAdapter>>,

    renderer: BackgroundRenderer,

    pub(super) static_background_renderer_data: Option<StaticBackgroundRendererData>,

    // Render offset accounts for global position and camera position
    pub(super) render_offset: Vector2,
}

#[godot_api]
impl IMeshInstance2D for BackgroundNode {
    fn enter_tree(&mut self) {
        self.render_offset = GameManager::singleton().bind().get_render_offset();
        setup_renderer(self);
        match self.renderer {
            BackgroundRenderer::Static => configure_static_background(self),
            _ => {
                godot_error!("BackgroundRenderer::configure_mesh: No renderer");
            }
        }

    }

    fn draw(&mut self) {
        match &self.renderer {
            BackgroundRenderer::Static => draw_static_background(self),
            _ => {
                godot_error!("BackgroundRenderer::draw: No renderer");
            }
        }
    }

    fn process(&mut self, delta: f64) {
        match &self.renderer {
            BackgroundRenderer::Static => process_static_background(self, delta),
            _ => {
                godot_error!("BackgroundRenderer::process: No renderer");
            }
        }
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
                render_offset: Vector2::new(0.0, 0.0),
                static_background_renderer_data: None,
            }
        })
    }
}

enum BackgroundRenderer {
    None,
    Static,
}

impl Default for BackgroundRenderer {
    fn default() -> Self {
        Self::None
    }
}

fn setup_renderer(node: &mut BackgroundNode) {
    let adapter = node.background.as_ref();

    if let Some(adapter) = adapter {
        let background = &adapter.bind().inner;
        let sprite_file_path = &adapter.bind().sprite_file_path;
        let game_manager_singleton = GameManager::singleton();
        let game_manager = game_manager_singleton.bind();
        let sprite_cache = game_manager.sprite_cache.bind();

        match background {
            Background::Static(static_background) => {
                let sprite_handle = sprite_cache.get_sprite_handle(sprite_file_path, static_background.spriteid);
                let sprite_data = sprite_cache.get_sprite_data(sprite_handle);

                if let Some(sprite_data) = sprite_data {
                    let texture_group = sprite_cache.get_texture_group(&sprite_data, None);
                    node.static_background_renderer_data = Some(StaticBackgroundRendererData {
                        static_background: static_background.clone(),
                        texture_group: texture_group.clone(),
                        sprite_data: sprite_data.clone(),
                    });
                    node.renderer = BackgroundRenderer::Static;
                }
            },
            _ => {
                godot_warn!("Unsupported background type: {:?}", background);
            }
        }
    }
}

