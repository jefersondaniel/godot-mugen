use glam::Vec2;
use godot::{classes::{mesh::PrimitiveType, ArrayMesh, IMeshInstance2D, MeshInstance2D, RenderingServer, ShaderMaterial, SurfaceTool}, prelude::*};
use crate::{adapters::BackgroundAdapter, assets::{SpriteData, TextureGroup}, GameManager};
use mugen_data::background::{background::Background, base_background::BaseBackground, static_background::StaticBackground};

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

    fn draw(&mut self) {
        self.renderer.configure_draw_rect(self);
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

    fn configure_draw_rect(&self, mesh_instance: &BackgroundNode) {
        match self {
            BackgroundRenderer::Static(data) => data.configure_draw_rect(mesh_instance),
            _ => {
                godot_error!("BackgroundRenderer::configure_draw_rect: No renderer");
            }
        }
    }
}

impl StaticBackgroundRendererData {
    fn create_mesh(&self, game_manager: &Gd<GameManager>) -> Gd<ArrayMesh> {
        let sprite_size = Vec2::new(
            self.sprite_data.image.width as f32,
            self.sprite_data.image.height as f32,
        );
        let sprite_offset = Vec2::new(
            self.sprite_data.sff_data.x as f32,
            self.sprite_data.sff_data.y as f32,
        );
        let viewport_size = game_manager.bind().get_viewport_size();
        let (tilestart, tileend) = get_tile_length(&self.static_background, sprite_size, Vec2::new(viewport_size.x, viewport_size.y));
        let tilingspacing = self.static_background.tilingspacing;
        let mut st = SurfaceTool::new_gd();

        st.begin(PrimitiveType::TRIANGLES);

        for y in (tilestart.y as i32)..(tileend.y as i32) {
            for x in (tilestart.x as i32)..(tileend.x as i32) {
                let adjustment = component_mul(sprite_size + tilingspacing, Vec2::new(x as f32, y as f32));
                let location = self.static_background.startlocation
                    + adjustment
                    - sprite_offset;

                add_quad(&mut st, location, sprite_size);
            }
        }
        let result = st.commit();

        if let Some(mesh) = result {
            return mesh;
        } else {
            godot_error!("Failed to create mesh");
            ArrayMesh::new_gd()
        }
    }

    fn create_material(&self, game_manager: &Gd<GameManager>) -> Gd<ShaderMaterial> {
        let sprite_shaders = &game_manager.bind().sprite_shaders;
        let material = create_sprite_material(&self.texture_group, sprite_shaders, self.static_background.blending);
        material
    }

    fn configure_mesh_instance(&self, node: &mut BackgroundNode) {
        let mut base = node.base_mut();
        let game_manager_singleton = GameManager::singleton();
        base.set_mesh(&self.create_mesh(&game_manager_singleton));
        base.set_material(&self.create_material(&game_manager_singleton));
        base.set_texture(&self.texture_group.image_texture);
    }

    fn configure_draw_rect(&self, node: &BackgroundNode) {
        // TODO: Evaluate performance impact here
        let base = node.base();
        let game_manager = GameManager::singleton();
        let game_manager_bind = game_manager.bind();
        let core_assets = game_manager_bind.core_assets.bind();
        let x_offset = -core_assets.get_localcoord().x / 2.0;
        if let Some(drawrect) = self.static_background.drawrect {
            let mut rendering_server = RenderingServer::singleton();
            let rect = Rect2::new(
                Vector2::new(drawrect.origin.x + x_offset, drawrect.origin.y),
                Vector2::new(drawrect.size.x, drawrect.size.y)
            );
            rendering_server.canvas_item_set_custom_rect_ex(base.get_canvas_item(), true).rect(rect).done();
            rendering_server.canvas_item_set_clip(base.get_canvas_item(), true);
        }
    }
}

fn add_quad(st: &mut SurfaceTool, offset: Vec2, size: Vec2) {
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

fn get_tile_length(background: &BaseBackground, sprite_size: Vec2, screen_size: Vec2) -> (Vec2, Vec2) {
    if !background.has_tiling() {
        return (
            Vec2::new(0.0, 0.0),
            Vec2::new(1.0, 1.0),
        )
    }

    let mut t = Vec2::new(0.0, 0.0);
    t.x = f32::ceil(1.0 + screen_size.x / sprite_size.x);
    t.y = f32::ceil(1.0 + screen_size.y / sprite_size.y);

    let mut start = Vec2::new(0.0, 0.0);
    let mut end = Vec2::new(0.0, 0.0);

    if background.tiling.x == 0.0 {
        start.x = 0.0;
        end.x = 1.0;
    } else if background.tiling.x == 1.0 {
        start.x = -f32::max(3.0, t.x);
        end.x = f32::max(3.0, t.x);
    } else {
        start.x = 0.0;
        end.x = background.tiling.x;
    }

    if background.tiling.y == 0.0 {
        start.y = 0.0;
        end.y = 1.0;
    } else if background.tiling.y == 1.0 {
        start.y = -f32::max(3.0, t.y);
        end.y = f32::max(3.0, t.y);
    } else {
        start.y = 0.0;
        end.y = background.tiling.y;
    }

    (start, end)
}

fn component_mul(a: Vec2, b: Vec2) -> Vec2 {
    Vec2::new(a.x * b.x, a.y * b.y)
}
