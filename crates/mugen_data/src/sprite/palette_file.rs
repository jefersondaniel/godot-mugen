use std::{io::Error, sync::Arc};

use crate::io::reader::DataReader;

use super::sff::{image::Palette, sffv1::{self, PaletteFileFormat}};

#[derive(Debug)]
pub struct PaletteFile {
    pub palette: Arc<Palette>,
}

impl PaletteFile {
    pub fn from_reader(reader: &mut dyn DataReader, format: PaletteFileFormat) -> Result<Self, Error> {
        reader.seek(0);

        let palette = sffv1::read_palette(reader, format)?;

        Ok(PaletteFile { palette })
    }

    pub fn detect_format(name: &str) -> Result<PaletteFileFormat, Error> {
        sffv1::detect_palette_format(name)
    }
}
