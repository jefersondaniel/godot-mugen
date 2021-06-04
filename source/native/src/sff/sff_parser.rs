use crate::sff::image::Palette;
use crate::sff::sff_common::{SffData, export_palette, import_palette};
use crate::sff::sffv1;
use crate::sff::sffv2;
use gdnative::prelude::*;
use std::rc::Rc;

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct SffParser {

}

#[methods]
impl SffParser {
    pub fn new(_owner: &Reference) -> Self {
        SffParser {
        }
    }

    #[export]
    pub fn read_metadata(&mut self, _owner: &Reference, path: String) -> Variant {
        let result_v2 = sffv2::read_metadata(&path);

        if result_v2.is_err() {
            let result_v1 = sffv1::read_metadata(&path);

            if let Ok(metadata) = result_v1 {
                return metadata.to_variant();
            }

            if let Err(message) = result_v1 {
                godot_error!("error: sffv1: {}", message);
            }

            return Variant::new();
        }

        if let Ok(metadata) = result_v2 {
            return metadata.to_variant()
        }

        Variant::new()
    }

    #[export]
    pub fn read_palette(&mut self, _owner: &Reference, path: String) -> Variant {
        let result = sffv1::read_palette(&path);

        match result {
            Ok(palette) => export_palette(palette).to_variant(),
            Err(error) => {
                godot_error!("error: read_palette: {}", error);

                Variant::new()
            }
        }
    }

    #[export]
    pub fn read_palettes(&mut self, _owner: &Reference, path: String) -> Variant {
        let result = sffv2::read_palettes(&path);

        match result {
            Ok(palettes) => {
                let result = VariantArray::new();

                for palette in palettes.iter() {
                    result.push(export_palette(Rc::clone(palette)).to_variant())
                }

                result.into_shared().to_variant()
            },
            Err(error) => {
                godot_error!("error: read_palette: {}", error);

                Variant::new()
            }
        }
    }

    #[export]
    pub fn read_images(&mut self, _owner: &Reference, path: String, palette: ColorArray, groups: Int32Array) -> Variant {
        let mut groups_vector: Vec<i16> = Vec::new();
        for i in 0..groups.len() {
            groups_vector.push(groups.get(i) as i16);
        }
        let palette_import = import_palette(palette);
        let result_v2 = sffv2::read_images(&path, &groups_vector);

        if result_v2.is_err() {
            let result_v1 = sffv1::read_images(&path, &groups_vector);

            if let Ok(mut sffdata) = result_v1 {
                return self.export_images(&mut sffdata, palette_import);
            }

            if let Err(message) = result_v1 {
                godot_error!("error: {}", message);
            }

            return Variant::new();
        }

        if let Ok(mut sffdata) = result_v2 {
            return self.export_images(&mut sffdata, palette_import);
        }

        Variant::new()
    }

    fn export_images(&self, sffdata: &mut Vec<SffData>, palette: Rc<Palette>) -> Variant {
        if !palette.is_empty() {
            for item in sffdata.iter_mut() {
                if item.palindex == 0 {
                    item.image.borrow_mut().color_table = Rc::clone(&palette);
                }
            }
        }

        let result = Dictionary::new();

        for item in sffdata.iter() {
            let dict = Dictionary::new();
            dict.insert("groupno", item.groupno);
            dict.insert("imageno", item.imageno);
            dict.insert("x", item.x);
            dict.insert("y", item.y);
            dict.insert("image", item.image.borrow().create_image());

            let key = format!("{}-{}", item.groupno, item.imageno);
            result.insert(key, dict);
        }

        result.into_shared().to_variant()
    }

    // #[export]
    // pub fn get_images(
    //     &mut self,
    //     _owner: &Reference,
    //     path: String,
    //     selected_pallete: Variant,
    // ) -> Variant {
    //     if !self.select_version(path) {
    //         godot_error!("error: invalid file. aborting");
    //         return Variant::new();
    //     }

    //     let palette: Rc<Palette>;

    //     match self.get_pallete(selected_pallete) {
    //         Ok(newpalette) => palette = newpalette,
    //         Err(message) => {
    //             godot_error!("error: {}", message);
    //             return Variant::new();
    //         }
    //     }

    //     if !palette.is_empty() {
    //         for i in 0..self.sffdata.len() {
    //             if self.sffdata[i].palindex == 0 {
    //                 self.sffdata[i].image.borrow_mut().color_table = Rc::clone(&palette);
    //             }
    //         }
    //     }

    //     self.create_dictionary().into_shared().to_variant()
    // }

    // fn create_dictionary(&mut self) -> Dictionary<Unique> {
    //     let result = Dictionary::new();

    //     for item in self.sffdata.iter() {
    //         let dict = Dictionary::new();
    //         dict.insert("groupno", item.groupno);
    //         dict.insert("imageno", item.imageno);
    //         dict.insert("x", item.x);
    //         dict.insert("y", item.y);
    //         dict.insert("image", item.image.borrow().create_image());

    //         let key = format!("{}-{}", item.groupno, item.imageno);
    //         result.insert(key, dict);
    //     }

    //     result
    // }

    // fn get_pallete(&mut self, selected_pallete: Variant) -> Result<Rc<Palette>, DataError> {
    //     match selected_pallete.get_type() {
    //         VariantType::I64 => {
    //             let selected_palette_index = i64::from_variant(&selected_pallete).unwrap();
    //             if selected_palette_index > 0 && selected_palette_index <= self.paldata.len() as i64
    //             {
    //                 Result::Ok(Rc::clone(
    //                     &self.paldata[selected_palette_index as usize - 1].pal,
    //                 ))
    //             } else if selected_palette_index <= 0 {
    //                 Result::Ok(Rc::new(Palette::empty()))
    //             } else {
    //                 Result::Err(DataError::new(format!(
    //                     "invalid palette index: {}",
    //                     selected_palette_index
    //                 )))
    //             }
    //         }
    //         VariantType::GodotString => {
    //             let act_extension = ".act";
    //             let palette_path = String::from_variant(&selected_pallete).unwrap();
    //             let palette_result;

    //             if palette_path.to_lowercase().ends_with(act_extension) {
    //                 palette_result = load_pal_format_act(palette_path);
    //             } else {
    //                 palette_result = load_pal_format_pal(palette_path);
    //             }

    //             palette_result
    //         }
    //         _ => Result::Err(DataError::new(
    //             "error: invalid selected pallete argument".to_string(),
    //         )),
    //     }
    // }

    // fn select_version(&mut self, path: String) -> bool {
    //     let v2 = sffv2::read(&path, &mut self.paldata, &mut self.sffdata);

    //     if v2.is_ok() {
    //         return true;
    //     } else if let Err(message) = v2 {
    //         let v1 = sffv1::read(&path, &mut self.paldata, &mut self.sffdata);
    //         godot_error!("error: sff v2: {}", message);
    //         if v1.is_ok() {
    //             return true;
    //         } else if let Err(message) = v1 {
    //             godot_error!("error: sff v1: {}", message);
    //         }
    //     }

    //     false
    // }
}
