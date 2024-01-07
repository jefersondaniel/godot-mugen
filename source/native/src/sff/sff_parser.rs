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

    #[method]
    pub fn read_metadata(&mut self, path: String) -> Variant {
        let result_v2 = sffv2::read_metadata(&path);

        if result_v2.is_err() {
            let result_v1 = sffv1::read_metadata(&path);

            if let Ok(metadata) = result_v1 {
                return metadata.to_variant();
            }

            if let Err(message) = result_v1 {
                godot_error!("error: sffv1: {}", message);
            }

            return Variant::nil();
        }

        if let Ok(metadata) = result_v2 {
            return metadata.to_variant()
        }

        Variant::nil()
    }

    #[method]
    pub fn read_palette(&mut self, path: String) -> Variant {
        let result = sffv1::read_palette(&path);

        match result {
            Ok(palette) => export_palette(palette).to_variant(),
            Err(error) => {
                godot_error!("error: read_palette: {}", error);

                Variant::nil()
            }
        }
    }

    #[method]
    pub fn read_palettes(&mut self, path: String) -> Variant {
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

                Variant::nil()
            }
        }
    }

    #[method]
    pub fn read_images(&mut self, path: String, palette: Variant, groups: Variant) -> Variant {
        let palette_import = self.parse_palette_argument(palette);
        let groups_vector: Vec<i16> = self.parse_groups_argument(groups);
        let result_v2 = sffv2::read_images(&path, &groups_vector);

        if result_v2.is_err() {
            let result_v1 = sffv1::read_images(&path, &groups_vector);

            if let Ok(mut sffdata) = result_v1 {
                return self.export_images(&mut sffdata, palette_import);
            }

            if let Err(message) = result_v1 {
                godot_error!("error: {}", message);
            }

            return Variant::nil();
        }

        if let Ok(mut sffdata) = result_v2 {
            return self.export_images(&mut sffdata, palette_import);
        }

        Variant::nil()
    }

    fn export_images(&self, sffdata: &mut Vec<SffData>, maybe_palette: Option<Rc<Palette>>) -> Variant {
        if let Some(palette) = maybe_palette {
            if !palette.is_empty() {
                for item in sffdata.iter_mut() {
                    if item.palindex == 0 {
                        item.image.borrow_mut().color_table = Rc::clone(&palette);
                    }
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

    pub fn parse_palette_argument(&self, variant: Variant) -> Option<Rc<Palette>> {
        match variant.get_type() {
            VariantType::ColorArray => Option::Some(import_palette(PoolArray::from_variant(&variant).unwrap())),
            _ => Option::None
        }
    }

    pub fn parse_groups_argument(&self, variant: Variant) -> Vec<i16> {
        match variant.get_type() {
            VariantType::Int32Array => {
                let mut result: Vec<i16> = Vec::new();
                let values: PoolArray<i32> = PoolArray::from_variant(&variant).unwrap();
                for i in 0..values.len() {
                    result.push(values.get(i) as i16);
                }
                result
            },
            VariantType::VariantArray => {
                let mut result: Vec<i16> = Vec::new();
                let values = VariantArray::from_variant(&variant).unwrap();
                for i in 0..values.len() {
                    let item = values.get(i);
                    result.push(i64::from_variant(&item).unwrap() as i16);
                }
                result
            },
            _ => Vec::new()
        }
    }
}
