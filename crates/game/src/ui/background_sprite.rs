use godot::prelude::*;
use crate::adapters::BackgroundAdapter;

#[derive(GodotClass)]
#[class(base=Node2D)]
pub struct BackgroundSprite {
    base: Base<Node2D>,

    #[var(get, set)]
    pub background: Option<Gd<BackgroundAdapter>>,
}

#[godot_api]
impl INode2D for BackgroundSprite {
    fn init(base: Base<Node2D>) -> Self {
        Self { base, background: None }
    }

    fn enter_tree(&mut self) {
        godot_print!("BackgroundSprite::enter_tree");
    }
}

#[godot_api]
impl BackgroundSprite {
    #[func]
    pub fn from_background(background: Gd<BackgroundAdapter>) -> Gd<Self> {
        Gd::from_init_fn(|base| {
            Self {
                background: Some(background),
                base,
            }
        })
    }
}
