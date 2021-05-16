use crate::sff::data::{ DataReader };

pub struct FileHeader {
    pub signature: String, // 12
    pub verlo3: u8,
    pub verlo2: u8,
    pub verlo1: u8,
    pub verhi: u8,
    pub total_sounds: u32,
    pub subheader_offset: u32,
    pub unused: Vec<u8>, // 488
}

pub struct SubHeader {
    pub next: u32,
    pub length: u32,
    pub groupno: u32,
    pub soundno: u32,
}

pub struct WavHeader {
    pub riff: Vec<u8>, // [u8; 4]
    pub chunk_size: u32,
    pub format: Vec<u8>, // [u8; 4]
    pub subchunk1_id: Vec<u8>, // [u8; 4]
    pub subchunk1_size: u32,
    pub audio_format: u16,
    pub num_channels: u16,
    pub sample_rate: u32,
    pub byte_rate: u32,
    pub block_align: u16,
    pub bits_per_sample: u16,
    pub subchunk2_id: Vec<u8>, // [u8, 4]
    pub subchunk2_size: u32,
}

impl FileHeader {
    pub fn read(reader: &mut dyn DataReader) -> FileHeader {
        FileHeader {
            signature: reader.get_text(12),
            verlo3: reader.get_u8(),
            verlo2: reader.get_u8(),
            verlo1: reader.get_u8(),
            verhi: reader.get_u8(),
            total_sounds: reader.get_u32(),
            subheader_offset: reader.get_u32(),
            unused: reader.get_buffer(488),
        }
    }
}

impl SubHeader {
    pub fn read(reader: &mut dyn DataReader) -> SubHeader {
        SubHeader {
            next: reader.get_u32(),
            length: reader.get_u32(),
            groupno: reader.get_u32(),
            soundno: reader.get_u32(),
        }
    }
}

impl WavHeader {
    pub fn read(reader: &mut dyn DataReader) -> WavHeader {
        WavHeader {
            riff: reader.get_buffer(4),
            chunk_size: reader.get_u32(),
            format: reader.get_buffer(4),
            subchunk1_id: reader.get_buffer(4),
            subchunk1_size: reader.get_u32(),
            audio_format: reader.get_u16(),
            num_channels: reader.get_u16(),
            sample_rate: reader.get_u32(),
            byte_rate: reader.get_u32(),
            block_align: reader.get_u16(),
            bits_per_sample: reader.get_u16(),
            subchunk2_id:reader.get_buffer(4),
            subchunk2_size: reader.get_u32(),
        }
    }
}
