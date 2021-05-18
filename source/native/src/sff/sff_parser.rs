use crate::sff::data::DataError;
use crate::sff::image::Palette;
use crate::sff::sff_common::{load_pal_format_act, load_pal_format_pal, SffData, SffPal};
use crate::sff::sffv1::read_v1;
use crate::sff::sffv2::read_v2;
use gdnative::prelude::*;
use std::rc::Rc;

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct SffParser {
    paldata: Vec<SffPal>,
    sffdata: Vec<SffData>,
}

#[methods]
impl SffParser {
    pub fn new(_owner: &Reference) -> Self {
        SffParser {
            paldata: Vec::new(),
            sffdata: Vec::new(),
        }
    }

    #[export]
    pub fn get_images(
        &mut self,
        _owner: &Reference,
        path: String,
        selected_pallete: Variant,
    ) -> Variant {
        if !self.select_version(path) {
            godot_print!("error: invalid file. aborting");
            return Variant::new();
        }

        let palette: Rc<Palette>;

        match self.get_pallete(selected_pallete) {
            Ok(newpalette) => palette = newpalette,
            Err(message) => {
                godot_print!("error: {}", message);
                return Variant::new();
            }
        }

        if !palette.is_empty() {
            for i in 0..self.sffdata.len() {
                if self.sffdata[i].palindex == 0 {
                    self.sffdata[i].image.borrow_mut().color_table = Rc::clone(&palette);
                }
            }
        }

        self.create_dictionary().into_shared().to_variant()
    }

    fn create_dictionary(&mut self) -> Dictionary<Unique> {
        let result = Dictionary::new();

        for item in self.sffdata.iter() {
            let dict = Dictionary::new();
            dict.insert("groupno", item.groupno);
            dict.insert("imageno", item.imageno);
            dict.insert("x", item.x);
            dict.insert("y", item.y);
            dict.insert("image", item.image.borrow().create_image());

            let key = format!("{}-{}", item.groupno, item.imageno);
            result.insert(key, dict);
        }

        result
    }

    fn get_pallete(&mut self, selected_pallete: Variant) -> Result<Rc<Palette>, DataError> {
        match selected_pallete.get_type() {
            VariantType::I64 => {
                let selected_palette_index = i64::from_variant(&selected_pallete).unwrap();
                if selected_palette_index > 0 && selected_palette_index <= self.paldata.len() as i64
                {
                    Result::Ok(Rc::clone(
                        &self.paldata[selected_palette_index as usize - 1].pal,
                    ))
                } else if selected_palette_index <= 0 {
                    Result::Ok(Rc::new(Palette::empty()))
                } else {
                    Result::Err(DataError::new(format!(
                        "invalid palette index: {}",
                        selected_palette_index
                    )))
                }
            }
            VariantType::GodotString => {
                let act_extension = ".act";
                let palette_path = String::from_variant(&selected_pallete).unwrap();
                let palette_result;

                if palette_path.to_lowercase().ends_with(act_extension) {
                    palette_result = load_pal_format_act(palette_path);
                } else {
                    palette_result = load_pal_format_pal(palette_path);
                }

                palette_result
            }
            _ => Result::Err(DataError::new(
                "error: invalid selected pallete argument".to_string(),
            )),
        }
    }

    fn select_version(&mut self, path: String) -> bool {
        let v2 = read_v2(path.to_string(), &mut self.paldata, &mut self.sffdata);

        if v2.is_ok() {
            return true;
        } else if let Err(message) = v2 {
            let v1 = read_v1(path, &mut self.paldata, &mut self.sffdata);
            godot_print!("error: sff v2: {}", message);
            if v1.is_ok() {
                return true;
            } else if let Err(message) = v1 {
                godot_print!("error: sff v1: {}", message);
            }
        }

        false
    }
}