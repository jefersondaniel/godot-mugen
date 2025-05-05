#[derive(Clone, Debug)]
pub struct VectorFont {
    pub path: String,
}

impl VectorFont {
    pub fn new(path: String) -> Self {
        Self { path }
    }
}
