use godot::prelude::*;
use godot::classes::{mesh::PrimitiveType, SurfaceTool};
use mugen_data::background::background::Background;
use super::{textures::BackgroundTextures, BackgroundGroupTextures, CoreAssets};

pub struct TitleScreenAssets {
    pub textures: BackgroundGroupTextures,
}

impl TitleScreenAssets {
    pub fn lala() {
        let mut st = SurfaceTool::new_gd();
        st.begin(PrimitiveType::TRIANGLES);
        st.add_vertex(Vector3::new(0.0, 0.0, 0.0));
    }
}
