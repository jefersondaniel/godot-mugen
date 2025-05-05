use std::{collections::HashMap, io::{Error, ErrorKind}};

use crate::io::reader::{BufferReader, DataReader};

use super::{sound_id::SoundId, structs::{FileHeader, SubHeader, WavHeader, WavSound}};

#[derive(Clone, Debug)]
pub struct SoundFile {
    sound_map: HashMap<SoundId, WavSound>,
}

impl SoundFile {
    pub fn from_reader(reader: &mut dyn DataReader) -> Result<Self, Error> {
        let sounds = read_sounds(reader)?;
        let mut sound_map = HashMap::new();

        for sound in sounds.iter() {
            sound_map.insert(sound.soundid, sound.clone());
        }

        Ok(Self::new(sound_map))
    }

    pub fn new(sound_map: HashMap<SoundId, WavSound>) -> Self {
        SoundFile { sound_map }
    }

    pub fn get_sound(&self, soundid: SoundId) -> Option<&WavSound> {
        return self.sound_map.get(&soundid)
    }
}

fn read_sounds(reader: &mut dyn DataReader) -> Result<Vec<WavSound>, Error> {
    let head = FileHeader::read(reader);

    if head.signature != "ElecbyteSnd" {
        return Result::Err(Error::new(
            ErrorKind::InvalidData,
            format!("Snd invalid signature: {}", head.signature)
        ));
    }

    reader.seek(head.subheader_offset as usize);

    let mut result = Vec::new();

    for _ in 0..4096 {
        if reader.eof() {
            break;
        }

        let subheader = SubHeader::read(reader);

        if subheader.length == 0 {
            break;
        }

        let tmp_arr = reader.get_buffer(subheader.length as usize);
        let mut tmp_arr_reader = BufferReader::new(tmp_arr.clone());
        let wav_header = WavHeader::read(&mut tmp_arr_reader);

        result.push(WavSound {
            soundid: SoundId::new(subheader.groupno as i16, subheader.soundno as i16),
            wav_header: wav_header.clone(),
            buffer: tmp_arr.clone(),
        });

        if subheader.next > 0 && subheader.next < reader.size() as u32 {
            reader.seek(subheader.next as usize);
        } else {
            break;
        }
    }

    Result::Ok(result)
}
