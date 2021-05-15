use std::fmt;
use std::io::Cursor;
use std::io::Read;
use gdnative::api::file::File;
use byteorder::{ ReadBytesExt, LittleEndian };

#[derive(Debug, Clone)]
pub struct DataError {
    pub message: String,
}

impl fmt::Display for DataError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.message.to_string())
    }
}

impl DataError {
    pub fn new(message: String) -> DataError {
        DataError { message }
    }
}

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
}

pub struct FileReader<'a> {
    file: &'a File,
    pos: usize,
}

impl<'a> FileReader<'a> {
    pub fn new(file: &'a File) -> FileReader {
        FileReader{ file, pos: 0 }
    }
}

impl<'a> DataReader for FileReader<'a> {
    fn get_bool(&mut self) -> bool {
        self.pos += 1;
        self.file.get_8() != 0
    }

    fn get_u8(&mut self) -> u8 {
        self.pos += 1;
        self.file.get_8() as u8
    }

    fn get_i8(&mut self) -> i8 {
        self.pos += 1;
        self.file.get_8() as i8
    }

    fn get_u16(&mut self) -> u16 {
        self.pos += 2;
        self.file.get_16() as u16
    }

    fn get_i16(&mut self) -> i16 {
        self.pos += 2;
        self.file.get_16() as i16
    }

    fn get_u32(&mut self) -> u32 {
        self.pos += 4;
        self.file.get_32() as u32
    }

    fn get_i32(&mut self) -> i32 {
        self.pos += 4;
        self.file.get_32() as i32
    }

    fn get_buffer(&mut self, size: usize) -> Vec<u8> {
        self.pos += size;
        let buffer = self.file.get_buffer(size as i64);
        // TODO: Improve performance here
        let mut vec: Vec<u8> = Vec::new();
        let size = buffer.len() as usize;
        vec.resize(size, 0);
        for i in 0..size {
            vec[i as usize] = buffer.get(i as i32);
        }
        vec
    }

    fn eof(&mut self) -> bool {
        self.file.eof_reached()
    }

    fn pos(&mut self) -> usize {
        self.pos
    }

    fn size(&mut self) -> usize {
        self.file.get_len() as usize
    }
}

pub struct BufferReader<'a> {
    buffer: &'a Vec<u8>,
    cursor: Cursor<&'a Vec<u8>>
}

impl<'a> BufferReader<'a> {
    pub fn new(buffer: &'a Vec<u8>) -> BufferReader {
        BufferReader{
            buffer,
            cursor: Cursor::new(buffer)
        }
    }
}

impl<'a> DataReader for BufferReader<'a> {
    fn get_bool(&mut self) -> bool {
        let result: Result<u8, u8> = self.cursor.read_u8().or_else(|_| Ok(0));

        result.unwrap() != 0
    }

    fn get_u8(&mut self) -> u8 {
        let result: Result<u8, u8> = self.cursor.read_u8().or_else(|_| Ok(0));

        result.unwrap()
    }

    fn get_i8(&mut self) -> i8 {
        let result: Result<i8, i8> = self.cursor.read_i8().or_else(|_| Ok(0));

        result.unwrap()
    }

    fn get_u16(&mut self) -> u16 {
        let result: Result<u16, u16> = self.cursor.read_u16::<LittleEndian>().or_else(|_| Ok(0));

        result.unwrap()
    }

    fn get_i16(&mut self) -> i16 {
        let result: Result<i16, i16> = self.cursor.read_i16::<LittleEndian>().or_else(|_| Ok(0));

        result.unwrap()
    }

    fn get_u32(&mut self) -> u32 {
        let result: Result<u32, u32> = self.cursor.read_u32::<LittleEndian>().or_else(|_| Ok(0));

        result.unwrap()
    }

    fn get_i32(&mut self) -> i32 {
        let result: Result<i32, i32> = self.cursor.read_i32::<LittleEndian>().or_else(|_| Ok(0));

        result.unwrap()
    }

    #[allow(unused_must_use)]
    fn get_buffer(&mut self, size: usize) -> Vec<u8> {
        let mut buf = vec![0u8; size];
        self.cursor.read_exact(&mut buf);
        buf
    }

    fn eof(&mut self) -> bool {
        self.cursor.position() >= self.buffer.len() as u64
    }

    fn pos(&mut self) -> usize {
        self.cursor.position() as usize
    }

    fn size(&mut self) -> usize {
        self.buffer.len()
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

        return self.subarray(start_index, actual_size - 1);
    }
}

impl BufferAccess for Vec<u8> {
    fn len(&self) -> usize {
        self.len()
    }

    fn subarray(&self, start: usize, end: usize) -> Vec<u8> {
        self[start..end].to_vec()
    }
}
