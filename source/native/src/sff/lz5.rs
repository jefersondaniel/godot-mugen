use crate::sff::data::{ BufferAccess, DataReader };

struct ControlPacket {
    flags: [u8; 8],
}

impl ControlPacket {
    fn read(reader: &mut dyn DataReader) -> ControlPacket {
        let mut flags: [u8; 8] = [0; 8];
        let byte = reader.get_u8();

        flags[7] = (byte & 0x80) / 0x80;
        flags[6] = (byte & 0x40) / 0x40;
        flags[5] = (byte & 0x20) / 0x20;
        flags[4] = (byte & 0x10) / 0x10;
        flags[3] = (byte & 0x08) / 0x08;
        flags[2] = (byte & 0x04) / 0x04;
        flags[1] = (byte & 0x02) / 0x02;
        flags[0] = byte & 0x01;

        ControlPacket { flags }
    }
}

struct Lz5RlePacket {
    color: u8,
    num_times: i64,
}

impl Lz5RlePacket {
    fn new() -> Lz5RlePacket {
        Lz5RlePacket {
            color: 0,
            num_times: 0,
        }
    }

    fn read(reader: &mut dyn DataReader, packet: &mut Lz5RlePacket) {
        {
            let byte1: u8 = reader.get_u8();
            let byte2: u8;
            packet.num_times = ((byte1 & 0xe0) >> 5) as i64;
            if packet.num_times == 0 {
                byte2 = reader.get_u8();
                packet.num_times = byte2 as i64;
                packet.num_times = packet.num_times + 8;
            }
            packet.color = byte1 & 0x1f;
        }
    }
}

struct Lz5LzPacket {
    len: i32,
    offset: i32,
    recycled: u8,
    recycled_bits_filled: u8,
}

impl Lz5LzPacket {
    fn new() -> Lz5LzPacket {
        Lz5LzPacket {
            len: 0,
            offset: 0,
            recycled: 0,
            recycled_bits_filled: 0,
        }
    }

    fn reset(&mut self) {
        self.recycled = 0;
        self.recycled_bits_filled = 0;
    }

    fn read(reader: &mut dyn DataReader, pack: &mut Lz5LzPacket) {
        let byte1: u8 = reader.get_u8();
        let byte2: u8;
        let byte3: u8;
        pack.len = (byte1 & 0x3f) as i32;
        if pack.len == 0 {
            byte2 = reader.get_u8();
            byte3 = reader.get_u8();
            pack.offset = (byte1 & 0xc0) as i32;
            pack.offset = pack.offset * 4;
            pack.offset = pack.offset + ( byte2 as i32 );
            pack.offset += 1;
            pack.len = byte3 as i32;
            pack.len = pack.len + 3;
        } else {
            pack.len += 1;
            let mut tmp_recyc: u8 = byte1 & 0xc0;
            if pack.recycled_bits_filled == 2 {
                tmp_recyc = tmp_recyc >> 2;
            }
            if pack.recycled_bits_filled == 4 {
                tmp_recyc = tmp_recyc >> 4;
            }
            if pack.recycled_bits_filled == 6 {
                tmp_recyc = tmp_recyc >> 6;
            }
            pack.recycled = pack.recycled + tmp_recyc;
            pack.recycled_bits_filled = pack.recycled_bits_filled +2;
            if pack.recycled_bits_filled < 8 {
                byte2 = reader.get_u8();
                pack.offset = byte2 as i32;
            }
            if pack.recycled_bits_filled == 8 {
                pack.offset = pack.recycled as i32;
                pack.reset();
            }
            pack.offset += 1;
        }
    }
}

pub fn decode_lz5(reader: &mut dyn DataReader) -> Vec<u8> {
    let mut dest: Vec<u8> = Vec::new();
    let mut rle = Lz5RlePacket::new();
    let mut lz = Lz5LzPacket::new();

    reader.get_u32(); // skip first 4 bytes (result size)
    while !reader.eof() {
        let ctrl = ControlPacket::read(reader);
        for a in 0..8 {
            if reader.eof() {
                break;
            }
            if ctrl.flags[a] == 0 {
                //rle packet
                Lz5RlePacket::read(reader, &mut rle);
                for _ in 0..rle.num_times {
                    dest.push(rle.color);
                }
            }
            if ctrl.flags[a] == 1 {
                //lz packet
                Lz5LzPacket::read(reader, &mut lz);
                let mut tmp_arr: Vec<u8> = dest.right(lz.offset as usize).to_vec();
                tmp_arr.truncate(lz.len as usize);
                while tmp_arr.len() < lz.len as usize {
                    tmp_arr.extend(tmp_arr.to_vec());
                    tmp_arr.truncate(lz.len as usize);
                }
                dest.extend(tmp_arr);
            }
        }
    }
    dest
}
