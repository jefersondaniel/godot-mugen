use godot::prelude::*;
use godot::{classes::FileAccess, classes::file_access::ModeFlags};

use crate::prelude::*;

pub fn start(game_manager: &mut GameManager) -> Result<()> {
    if game_manager.configuration_directory.is_empty() {
        return Err(anyhow::anyhow!("Configuration directory does not exist"));
    }

    let configuration_path = join_paths(&[game_manager.configuration_directory.to_string().as_str(), "data/mugen.cfg"]);

    let file = FileAccess::open(&GString::from(configuration_path), ModeFlags::READ);

    if let Some(file) = file {
        Ok(())
    } else {
        return Err(anyhow::anyhow!("Configuration file does not exist"));
    }
}

pub fn update(game_manager: &mut GameManager) -> Result<Option<GameState>> {
    Ok(None)
}
