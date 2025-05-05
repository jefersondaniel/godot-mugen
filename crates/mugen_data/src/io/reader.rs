use byteorder::{LittleEndian, ReadBytesExt};
use std::io::Cursor;
use std::io::Read;

pub trait DataReader {
    fn get_bool(&mut self) -> bool;
    fn get_u8(&mut self) -> u8;
    fn get_i8(&mut self) -> i8;
    fn get_u16(&mut self) -> u16;
    fn get_i16(&mut self) -> i16;
    fn get_u32(&mut self) -> u32;
    fn get_i32(&mut self) -> i32;
    fn get_buffer(&mut self, size: usize) -> Vec<u8>;
    fn eof(&mut self) -> bool;
    fn pos(&mut self) -> usize;
    fn size(&mut self) -> usize;
    fn get_text(&mut self, size: usize) -> String {
        let buffer = self.get_buffer(size);
        let mut text = String::from("");
        let mut i = 0;
        while i < buffer.len() {
            let code = buffer[i];
            if code == 0 {
                // skip null byte
                break;
            }
            let character = code as char;
            text.push(character);
            i += 1;
        }
        text
    }
    fn get_line(&mut self) -> String {
        let mut buffer = Vec::new();
        let mut byte = self.get_u8();
        while byte != 0x0A {
            buffer.push(byte);
            byte = self.get_u8();
        }
        String::from_utf8(buffer).unwrap()
    }
    fn get_as_text(&mut self) -> String {
        let size = self.size();
        let buffer = self.get_buffer(size);
        let mut text = String::from("");
        let mut i = 0;
        while i < buffer.len() {
            let code = buffer[i];
            let character = code as char;
            text.push(character);
            i += 1;
        }
        text
    }
    fn seek(&mut self, position: usize);
}

pub struct BufferReader {
    size: usize,
    cursor: Cursor<Vec<u8>>,
}

impl BufferReader {
    pub fn new(buffer: Vec<u8>) -> BufferReader {
        let size = buffer.len();
        BufferReader {
            size,
            cursor: Cursor::new(buffer),
        }
    }
}

impl DataReader for BufferReader {
    fn get_bool(&mut self) -> bool {
        let result: Result<u8, u8> = self.cursor.read_u8().or(Ok(0));

        result.unwrap() != 0
    }

    fn get_u8(&mut self) -> u8 {
        let result: Result<u8, u8> = self.cursor.read_u8().or(Ok(0));

        result.unwrap()
    }

    fn get_i8(&mut self) -> i8 {
        let result: Result<i8, i8> = self.cursor.read_i8().or(Ok(0));

        result.unwrap()
    }

    fn get_u16(&mut self) -> u16 {
        let result: Result<u16, u16> = self.cursor.read_u16::<LittleEndian>().or(Ok(0));

        result.unwrap()
    }

    fn get_i16(&mut self) -> i16 {
        let result: Result<i16, i16> = self.cursor.read_i16::<LittleEndian>().or(Ok(0));

        result.unwrap()
    }

    fn get_u32(&mut self) -> u32 {
        let result: Result<u32, u32> = self.cursor.read_u32::<LittleEndian>().or(Ok(0));

        result.unwrap()
    }

    fn get_i32(&mut self) -> i32 {
        let result: Result<i32, i32> = self.cursor.read_i32::<LittleEndian>().or(Ok(0));

        result.unwrap()
    }

    #[allow(unused_must_use)]
    fn get_buffer(&mut self, size: usize) -> Vec<u8> {
        let mut buf = vec![0u8; size];
        self.cursor.read_exact(&mut buf);
        buf
    }

    fn eof(&mut self) -> bool {
        self.cursor.position() >= self.size as u64
    }

    fn pos(&mut self) -> usize {
        self.cursor.position() as usize
    }

    fn size(&mut self) -> usize {
        self.size
    }

    fn seek(&mut self, position: usize) {
        self.cursor.set_position(position as u64);
    }
}

pub trait BufferAccess {
    fn len(&self) -> usize;

    fn subarray(&self, start: usize, end: usize) -> Vec<u8>;

    fn right(&self, new_size: usize) -> Vec<u8> {
        let actual_size = self.len();

        if new_size >= actual_size {
            return self.subarray(0, actual_size - 1);
        }

        let start_index = actual_size - new_size;

        self.subarray(start_index, actual_size - 1)
    }
}

impl BufferAccess for Vec<u8> {
    fn len(&self) -> usize {
        self.len()
    }

    fn subarray(&self, start: usize, end: usize) -> Vec<u8> {
        let mysize = self.len();

        if start > end || end > mysize - 1 || start > mysize - 1 || mysize == 0 {
            return self[..].to_vec();
        }

        self[start..end + 1].to_vec()
    }
}
