use godot::{classes::{canvas_item::TextureFilter, mesh::PrimitiveType, ArrayMesh, IMeshInstance2D, MeshInstance2D, SurfaceTool}, prelude::*};
use crate::{adapters::BackgroundAdapter, assets::{SpriteData, TextureGroup}, GameManager};
use mugen_data::background::{background::Background, static_background::StaticBackground};

use super::material::create_sprite_material;

#[derive(GodotClass)]
#[class(init, base=MeshInstance2D)]
pub struct BackgroundNode {
    base: Base<MeshInstance2D>,

    #[var(get, set)]
    pub background: Option<Gd<BackgroundAdapter>>,

    renderer: BackgroundRenderer,
}

#[godot_api]
impl IMeshInstance2D for BackgroundNode {
    fn enter_tree(&mut self) {
        let renderer = BackgroundRenderer::from(&self.background);
        renderer.configure_mesh_instance(self);
        self.renderer = renderer;
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
   texture_group: TextureGroup,
   sprite_data: SpriteData,
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

impl From<&Option<Gd<BackgroundAdapter>>> for BackgroundRenderer {
    fn from(adapter: &Option<Gd<BackgroundAdapter>>) -> Self {
        if let Some(adapter) = adapter {
            let background = &adapter.bind().inner;
            let game_manager_singleton = GameManager::singleton();
            let game_manager = game_manager_singleton.bind();
            let core_assets = game_manager.core_assets.bind();
            let sprite_cache = game_manager.sprite_cache.bind();
            let sprite_file_path = &core_assets.motif_sprite_file_path;

            match background {
                Background::Static(static_background) => {
                    let sprite_handle = sprite_cache.get_sprite_handle(sprite_file_path, static_background.spriteid);
                    let sprite_data = sprite_cache.get_sprite_data(sprite_handle);

                    if let Some(sprite_data) = sprite_data {
                        let texture_group = sprite_cache.get_texture_group(&sprite_data, None);
                        Self::Static(StaticBackgroundRendererData {
                            static_background: static_background.clone(),
                            texture_group: texture_group.clone(),
                            sprite_data: sprite_data.clone(),
                        })
                    } else {
                        Self::None
                    }
                },
                _ => Self::None,
            }
        } else {
            Self::None
        }
    }
}

impl BackgroundRenderer {
    fn configure_mesh_instance(&self, mesh_instance: &mut BackgroundNode) {
        match self {
            BackgroundRenderer::Static(data) => data.configure_mesh_instance(mesh_instance),
            _ => {
                godot_error!("BackgroundRenderer::configure_mesh_instance: No renderer");
            }
        }
    }
}

impl StaticBackgroundRendererData {
    fn create_mesh(&self) -> Gd<ArrayMesh> {
        let mut st = SurfaceTool::new_gd();
        let offset = Vector2::new(0.0, 0.0);
        let size = Vector2::new(
            // TODO: Adjust scale
            self.sprite_data.image.width as f32,
            self.sprite_data.image.height as f32,
        );
        st.begin(PrimitiveType::TRIANGLES);
        add_quad(&mut st, offset, size);
        let result = st.commit();

        if let Some(mesh) = result {
            mesh
        } else {
            godot_error!("Failed to create mesh");
            ArrayMesh::new_gd()
        }
    }

    fn configure_mesh_instance(&self, node: &mut BackgroundNode) {
        let mut base = node.base_mut();
        let game_manager_singleton = GameManager::singleton();
        let material = create_sprite_material(&self.texture_group, &game_manager_singleton.bind().sprite_shader);
        base.set_mesh(&self.create_mesh());
        base.set_material(&material);
        base.set_texture(&self.texture_group.image_texture);
    }
}

fn add_quad(st: &mut SurfaceTool, offset: Vector2, size: Vector2) {
    let top_left_uv = Vector2::new(0.0, 0.0);
    let top_right_uv = Vector2::new(1.0, 0.0);
    let bottom_left_uv = Vector2::new(0.0, 1.0);
    let bottom_right_uv = Vector2::new(1.0, 1.0);

    let top_left_pos = Vector3::new(offset.x, offset.y, 0.0);
    let top_right_pos = Vector3::new(offset.x + size.x, offset.y, 0.0);
    let bottom_left_pos = Vector3::new(offset.x, offset.y + size.y, 0.0);
    let bottom_right_pos = Vector3::new(offset.x + size.x, offset.y + size.y, 0.0);

    // First Triangle
    st.set_uv(top_left_uv);
    st.add_vertex(top_left_pos);
    st.set_uv(top_right_uv);
    st.add_vertex(top_right_pos);
    st.set_uv(bottom_left_uv);
    st.add_vertex(bottom_left_pos);

    // Second Triangle
    st.set_uv(top_right_uv);
    st.add_vertex(top_right_pos);
    st.set_uv(bottom_right_uv);
    st.add_vertex(bottom_right_pos);
    st.set_uv(bottom_left_uv);
    st.add_vertex(bottom_left_pos);
}
