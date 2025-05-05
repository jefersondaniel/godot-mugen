use std::ops::Deref;

use std::{collections::HashMap, io::Error};

use crate::{audio::sound_id::SoundId, enumerations::MainMenuOption, font::print_data::PrintData, text::{text_file::TextFile, text_section::TextSection}, types::Vector2};

use super::non_combat_screen::NonCombatScreen;

#[derive(Clone, Debug, Default)]
pub struct TitleScreen {
    pub non_combat_screen: NonCombatScreen,
    pub menuposition: Vector2,
    pub mainfont: PrintData,
    pub activefont: PrintData,
    pub spacing: Vector2,
    pub visiblemenuitems: i32,
    pub cursorvisible: bool,
    pub soundcursormove: Option<SoundId>,
    pub soundselect: Option<SoundId>,
    pub soundcancel: Option<SoundId>,
    pub menutext: HashMap<MainMenuOption, String>,
    pub marginytop: i32,
    pub marginybottom: i32,
}

impl Deref for TitleScreen {
    type Target = NonCombatScreen;

    fn deref(&self) -> &Self::Target {
        &self.non_combat_screen
    }
}

impl TitleScreen {
    pub fn parse(
        textfile: &TextFile,
    ) -> Result<Self, Error> {
        let section = textfile.get_section("Title Info")?;
        let marginy: Vector2 = section.get_attribute_or_default("menu.window.margins.y");

        let non_combat_screen = NonCombatScreen::parse(
            &textfile,
            &section,
            "Title",
        )?;

        Ok(TitleScreen {
            non_combat_screen: non_combat_screen,
            menuposition: section.get_attribute_or_fail("menu.pos")?,
            mainfont: section.get_attribute_or_fail("menu.item.font")?,
            activefont: section.get_attribute_or_fail("menu.item.active.font")?,
            spacing: section.get_attribute_or_fail("menu.item.spacing")?,
            visiblemenuitems: section.get_attribute_or_fail("menu.window.visibleitems")?,
            cursorvisible: section.get_attribute_or_fail("menu.boxcursor.visible")?,
            soundcursormove: section.get_attribute("cursor.move.snd"),
            soundselect: section.get_attribute("cursor.done.snd"),
            soundcancel: section.get_attribute("cancel.snd"),
            menutext: build_menu_text(&section),
            marginytop: marginy.x as i32,
            marginybottom: marginy.y as i32,
        })
    }
}

fn build_menu_text(textsection: &TextSection) -> HashMap<MainMenuOption, String> {
    let mut map = HashMap::new();
    // map.insert(MainMenuOption::Arcade, textsection.get_attribute_or_default("menu.itemname.arcade"));
    map.insert(MainMenuOption::Versus, textsection.get_attribute_or_default("menu.itemname.versus"));
    // map.insert(MainMenuOption::TeamArcade, textsection.get_attribute_or_default("menu.itemname.teamarcade"));
    // map.insert(MainMenuOption::TeamVersus, textsection.get_attribute_or_default("menu.itemname.teamversus"));
    // map.insert(MainMenuOption::TeamCoop, textsection.get_attribute_or_default("menu.itemname.teamcoop"));
    // map.insert(MainMenuOption::Survival, textsection.get_attribute_or_default("menu.itemname.survival"));
    // map.insert(MainMenuOption::SurvivalCoop, textsection.get_attribute_or_default("menu.itemname.survivalcoop"));
    map.insert(MainMenuOption::Training, textsection.get_attribute_or_default("menu.itemname.training"));
    // map.insert(MainMenuOption::Watch, textsection.get_attribute_or_default("menu.itemname.watch"));
    // map.insert(MainMenuOption::Options, textsection.get_attribute_or_default("menu.itemname.options"));
    // map.insert(MainMenuOption::Quit, textsection.get_attribute_or_default("menu.itemname.exit"));
    // TODO: Implement missing menus
    // map.insert(MainMenuOption::TeamCoop, "NOT IMPLEMENTED".to_string());
    // map.insert(MainMenuOption::Survival, "NOT IMPLEMENTED".to_string());
    // map.insert(MainMenuOption::SurvivalCoop, "NOT IMPLEMENTED".to_string());
    // map.insert(MainMenuOption::Training, "NOT IMPLEMENTED".to_string());
    // map.insert(MainMenuOption::Watch, "NOT IMPLEMENTED".to_string());
    // map.insert(MainMenuOption::Options, "NOT IMPLEMENTED".to_string());
    map
}
