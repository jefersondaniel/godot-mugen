use godot::prelude::*;
use crate::adapters::BackgroundAdapter;
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

        match background {
            Background::Static(static_background) => Self::Static(StaticBackgroundRendererData {
                static_background: static_background.clone()
            }),
            _ => Self::None,
        }
    }
}
