use gdnative::prelude::*;
use gdnative::api::file::File;
use crate::snd::structs::{ FileHeader, SubHeader, WavHeader };
use crate::sff::data::{ DataReader, DataError, FileReader, BufferReader };

#[derive(NativeClass)]
#[inherit(Reference)]
pub struct SndParser {
}

#[methods]
impl SndParser {
    pub fn new(_owner: &Reference) -> Self {
        SndParser { }
    }

    #[export]
    pub fn get_sounds(&self, _owner: &Reference, path: String) -> Variant {
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
            return Result::Err(DataError::new(format!("Error opening snd file: {}", detail)));
        }

        let mut reader = FileReader::new(&file);
        let head = FileHeader::read(&mut reader);

        if head.signature != "ElecbyteSnd" {
            file.close();
            return Result::Err(DataError::new(format!("Snd invalid signature: {}", head.signature)));
        }

        file.seek(head.subheader_offset as i64);

        let result = Dictionary::new();

        for _ in 0..4096 {
            if reader.eof() {
                break;
            }

            let subheader = SubHeader::read(&mut reader);

            if subheader.length == 0 {
                break;
            }

            let tmp_arr = reader.get_buffer(subheader.length as usize);
            let mut tmp_arr_reader = BufferReader::new(&tmp_arr);
            let wav_header = WavHeader::read(&mut tmp_arr_reader);

            let dict = Dictionary::new();
            dict.insert("groupno", subheader.groupno);
            dict.insert("soundno", subheader.soundno);
            dict.insert("audio_format", wav_header.audio_format);
            dict.insert("num_channels", wav_header.num_channels);
            dict.insert("sample_rate", wav_header.sample_rate);
            dict.insert("byte_rate", wav_header.byte_rate);
            dict.insert("block_align", wav_header.block_align);
            dict.insert("bits_per_sample", wav_header.bits_per_sample);
            dict.insert("data", to_signed(&tmp_arr));

            let key = format!("{}-{}", subheader.groupno, subheader.soundno);
            result.insert(key, dict);

            if subheader.next > 0 && subheader.next < file.get_len() as u32 {
                file.seek(subheader.next as i64);
            } else {
                break;
            }
        }

        file.close();

        return Result::Ok(result.into_shared());
    }
}

fn to_signed(source: &Vec<u8>) -> ByteArray {
    source.iter()
        .map(| value | ((*value as i16) - 128) as u8)
        .collect()
}
