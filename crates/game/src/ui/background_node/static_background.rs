use glam::Vec2;
use godot::{classes::{canvas_item::TextureFilter, mesh::PrimitiveType, ArrayMesh, RenderingServer, SurfaceTool}, prelude::*};
use mugen_data::background::{BaseBackground, StaticBackground};

use crate::{assets::{SpriteData, TextureGroup}, GameManager};

use super::{common_background::create_material, BackgroundNode};

pub(super) struct StaticBackgroundRendererData {
    pub(super) static_background: StaticBackground,
    pub(super) texture_group: TextureGroup,
    pub(super) sprite_data: SpriteData,
}

pub(super) fn configure_static_background(
    node: &mut BackgroundNode
) {
    let game_manager_singleton = GameManager::singleton();
    let (material, mesh, image_texture) = {
        let data = {
            node.static_background_renderer_data.as_ref().unwrap()
        };
        let material = create_material(&data.texture_group, data.static_background.blending, &game_manager_singleton);
        let mesh = create_mesh(&data);
        let image_texture = data.texture_group.image_texture.clone();

        (material, mesh, image_texture)
    };
    let mut base = node.base_mut();
    base.set_mesh(&mesh);
    base.set_material(&material);
    base.set_texture(&image_texture);
    base.set_texture_filter(TextureFilter::NEAREST);
}

pub(super) fn draw_static_background(node: &BackgroundNode) {
    configure_draw_rect(node);
}

pub(super) fn process_static_background(node: &mut BackgroundNode, delta: f64) {
    apply_velocity(node, delta);
}

fn create_mesh(data: &StaticBackgroundRendererData) -> Gd<ArrayMesh> {
    let sprite_size: Vec2 = Vec2::new(
        data.sprite_data.image.width as f32,
        data.sprite_data.image.height as f32,
    );
    let sprite_offset = Vec2::new(
        data.sprite_data.sff_data.x as f32,
        data.sprite_data.sff_data.y as f32,
    );
    let viewport_size = GameManager::singleton().bind().get_viewport_size();
    let (tilestart, tileend) = get_tile_length(&data.static_background, sprite_size, Vec2::new(viewport_size.x, viewport_size.y));
    let tilingspacing = data.static_background.tilingspacing;
    let mut st = SurfaceTool::new_gd();

    st.begin(PrimitiveType::TRIANGLES);

    for y in (tilestart.y as i32)..(tileend.y as i32) {
        for x in (tilestart.x as i32)..(tileend.x as i32) {
            let adjustment = component_mul(sprite_size + tilingspacing, Vec2::new(x as f32, y as f32));
            let location = data.static_background.startlocation
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

fn apply_velocity(node: &mut BackgroundNode, delta: f64) {
    let (startlocation, velocity, sprite_size) = {
        let data = node.static_background_renderer_data.as_ref().unwrap();
        let startlocation = data.static_background.startlocation;
        let velocity = data.static_background.base_background.velocity * 60.0;
        let sprite_size = Vector2::new(
            data.sprite_data.image.width as f32,
            data.sprite_data.image.height as f32,
        );

        (startlocation, velocity, sprite_size)
    };

    // Skip if no velocity
    if velocity == Vec2::new(0.0, 0.0) {
        return;
    }

    // Apply velocity to transform
    let mut transform = node.base().get_transform();
    let scaled_velocity = Vector2::new(velocity.x * delta as f32, velocity.y * delta as f32);
    transform = transform.translated(scaled_velocity);

    // Get current location and sprite size
    let location = transform.origin;

    // Reset X position if out of bounds
    if location.x >= startlocation.x + sprite_size.x || location.x <= startlocation.x - sprite_size.x {
        transform.origin.x = startlocation.x;
    }

    // Reset Y position if out of bounds
    if location.y >= startlocation.y + sprite_size.y || location.y <= startlocation.y - sprite_size.y {
        transform.origin.y = startlocation.y;
    }

    // Apply the updated transform
    node.base_mut().set_transform(transform);
    configure_draw_rect(node);
}

fn configure_draw_rect(node: &BackgroundNode) {
    let data = node.static_background_renderer_data.as_ref().unwrap();
    let base = node.base();
    if let Some(drawrect) = data.static_background.drawrect {
        let mut rendering_server = RenderingServer::singleton();
        let draw_rect_origin = Vector2::new(drawrect.origin.x + node.render_offset.x, drawrect.origin.y + node.render_offset.y);
        let inverse_transform = base.get_transform().affine_inverse();
        let rect = Rect2::new(
            inverse_transform * draw_rect_origin,
            Vector2::new(drawrect.size.x, drawrect.size.y)
        );
        rendering_server.canvas_item_set_custom_rect_ex(base.get_canvas_item(), true).rect(rect).done();
        rendering_server.canvas_item_set_clip(base.get_canvas_item(), true);
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
