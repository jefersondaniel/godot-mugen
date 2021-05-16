use gdnative::prelude::*;
use gdnative::api::file::File;
use crate::sff::data::{ DataReader, DataError, FileReader, BufferReader };
use crate::sff::pcx::{ read_pcx };

#[allow(dead_code)]
pub struct FileHeader {
    signature: String,
    verlo3: u8,
    verlo2: u8,
    verlo1: u8,
    verhi: u8,
    pcx_offset: u32,
    pcx_size: u32,
    text_offset: u32,
    text_size: u32,
    unused: Vec<u8>,
}

impl FileHeader {
    pub fn read(reader: &mut dyn DataReader) -> FileHeader {
        FileHeader {
            signature: reader.get_text(12),
            verlo3: reader.get_u8(),
            verlo2: reader.get_u8(),
            verlo1: reader.get_u8(),
            verhi: reader.get_u8(),
            pcx_offset: reader.get_u32(),
            pcx_size: reader.get_u32(),
            text_offset: reader.get_u32(),
            text_size: reader.get_u32(),
            unused: reader.get_buffer(40),
        }
    }
}

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct FntParser {
}

#[methods]
impl FntParser {
    pub fn new(_owner: &Reference) -> Self {
        FntParser { }
    }

    #[export]
    pub fn get_font_data(&self, _owner: &Reference, path: String) -> Variant {
        let result = self.read_file(path);

        if let Ok(dict) = result {
            return dict.to_variant();
        } else if let Err(message) = result {
            godot_print!("error: {}", message);
        }

        Variant::new()
    }

    pub fn read_file(&self, path: String) -> Result<Dictionary, DataError> {
        let file = File::new();
        let open_result = file.open(path, File::READ);

        if let Err(detail) = open_result {
            return Result::Err(DataError::new(format!("Error opening fnt file: {}", detail)));
        }

        let mut reader = FileReader::new(&file);
        let head = FileHeader::read(&mut reader);

        if head.signature != "ElecbyteFnt" {
            file.close();
            return Result::Err(DataError::new(format!("Fnt invalid signature: {}", head.signature)));
        }

        file.seek(head.text_offset as i64);
        let text = reader.get_text(head.text_size as usize);

        file.seek(head.pcx_offset as i64);
        let pcx_arr = reader.get_buffer(head.pcx_size as usize);
        let mut pcx_arr_reader = BufferReader::new(&pcx_arr);
        let image_result = read_pcx(&mut pcx_arr_reader);

        match image_result {
            Ok(image) => {
                let result = Dictionary::new();
                result.insert("image", image.borrow().create_image());
                result.insert("text", text);

                file.close();

                Result::Ok(result.into_shared())
            },
            Err(message) => {
                file.close();
                Result::Err(DataError::new(message.to_string()))
            }
        }
    }
}
