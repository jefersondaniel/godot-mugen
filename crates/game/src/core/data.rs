use godot::classes::file_access::ModeFlags;
use godot::classes::FileAccess;
use godot::prelude::*;
use mugen_data::io::file::FileReader;
use mugen_data::io::reader::DataReader;

pub struct GodotFilesystem {}

impl FileReader for GodotFilesystem {
    fn read(&self, path: &str) -> Result<Box<dyn DataReader>, std::io::Error> {
        let file = FileAccess::open(&GString::from(path), ModeFlags::READ);
        if let Some(file) = file {
            let reader = GodotFileReader::new(file);
            Ok(Box::new(reader))
        } else {
            Err(std::io::Error::new(std::io::ErrorKind::Other, "File does not exist"))
        }
    }

    fn does_file_exist(&self, path: &str) -> bool {
        FileAccess::file_exists(&GString::from(path))
    }
}

pub struct GodotFileReader {
    file: Gd<FileAccess>,
    pos: usize,
}

impl GodotFileReader {
    pub fn new(file: Gd<FileAccess>) -> Self {
        Self { file, pos: 0 }
    }
}

impl DataReader for GodotFileReader {
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
        self.file.get_buffer(size as i64).to_vec()
    }

    fn eof(&mut self) -> bool {
        self.file.eof_reached()
    }

    fn pos(&mut self) -> usize {
        self.pos
    }

    fn seek(&mut self, position: usize) {
        self.file.seek(position as u64);
    }

    fn size(&mut self) -> usize {
        self.file.get_length() as usize
    }
}

