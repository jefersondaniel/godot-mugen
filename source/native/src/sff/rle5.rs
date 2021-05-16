use crate::sff::data::DataReader;

struct Rle5Packet {
    run_len: u8,
    color_bit: u8,
    data_len: u8,
}

impl Rle5Packet {
    fn read(reader: &mut dyn DataReader) -> Rle5Packet {
        let mut rle5 = Rle5Packet {
            run_len: 0,
            color_bit: 0,
            data_len: 0,
        };
        rle5.run_len = reader.get_u8();
        {
            let byte_process = reader.get_u8();
            rle5.color_bit = (byte_process & 0x80) / 0x80;
            rle5.data_len = byte_process & 0x7f;
        }
        rle5
    }
}

pub fn decode_rle5(reader: &mut dyn DataReader) -> Vec<u8> {
    let mut dest: Vec<u8> = Vec::new();
    {
        let mut color: u8 = 0;
        reader.get_u32(); // skip first 4 bytes (result size)
        while !reader.eof() {
            let rle5 = Rle5Packet::read(reader);
            if rle5.color_bit == 1 {
                color = reader.get_u8();
            }
            if rle5.color_bit == 0 {
                color = 0;
            }
            for _ in 0..rle5.run_len {
                dest.push(color);
            }
            for _ in 0..rle5.data_len {
                let one_byte = reader.get_u8();
                color = one_byte & 0x1f;
                let run_len: u8 = one_byte >> 5;
                for _ in 0..run_len {
                    dest.push(color);
                }
            }
        }
    }
    dest
}

pub fn decode_rle8(reader: &mut dyn DataReader) -> Vec<u8> {
    let mut dest: Vec<u8> = Vec::new();
    let mut ch: u8;
    let mut color: u8;

    reader.get_u32(); // skip first 4 bytes

    while !reader.eof() {
        ch = reader.get_u8();
        if (ch & 0xc0) == 0x40 {
            color = reader.get_u8();
            for _ in 0..(ch & 0x3f) {
                dest.push(color);
            }
        }
        if (ch & 0xc0) != 0x40 {
            dest.push(ch);
        }
    }

    dest
}
