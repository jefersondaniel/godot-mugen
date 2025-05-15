use std::{io::Error, path::{PathBuf, Path}, ffi::OsStr};

use crate::text::text_file::TextFile;

use super::reader::DataReader;

pub trait FileReader {
    fn read(&self, path: &str) -> Result<Box<dyn DataReader>, Error>;
    fn does_file_exist(&self, path: &str) -> bool;
    fn get_path_by_referrer(&self, name: &str, referrer: &str) -> String {
        let mut directory = get_directory(referrer);
        let mut path = combine_paths(&directory, name);

        for _ in 0..2 {
            if !self.does_file_exist(&path) {
                directory = get_directory(&directory);
                path = combine_paths(&directory, name);
                continue;
            }

            break;
        }

        path
    }
    fn read_text_file(&self, path: &str) -> Result<TextFile, Error> {
        let mut reader = self.read(path)?;
        TextFile::from_reader(reader.as_mut())
    }
}

pub fn combine_paths(lhs: &str, rhs: &str) -> String {
    return format!("{}/{}", lhs.trim_end_matches('/'), rhs.trim_start_matches('/'))
}

pub fn get_directory(filepath: &str) -> String {
    let mut path_buf = PathBuf::from(filepath);
    path_buf.pop();
    path_buf.to_str().unwrap().to_string()
}

pub fn get_name(filepath: &str) -> String {
    let path_buff = Path::new(filepath);
    let default = OsStr::new("");
    let result = path_buff.file_name().unwrap_or(&default);
    result.to_str().unwrap_or("").to_string()
}
