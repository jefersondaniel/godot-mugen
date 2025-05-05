use std::io::{Error, ErrorKind};

use crate::{attribute_value::{AttributeValue, ParseAttributeValue}, enumerations::PrintJustification, types::Color};

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Hash)]
pub struct PrintData {
    pub index: i16,
    pub colorindex: i16,
    pub justification: PrintJustification,
    pub color: Option<Color>,
}

impl ParseAttributeValue for PrintData {
    fn parse_attribute_value(value: AttributeValue) -> Result<PrintData, Error> {
        let values = value.split_values();

        if values.len() >= 2 {
            let index = values[0].parse::<i16>()
                .map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid index: {}", values[0])))?;
            let colorindex = values[0].parse::<i16>()
                .map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid index: {}", values[1])))?;
            let mut justification = PrintJustification::Center;
            let mut color = None;

            if values.len() >= 3 {
                justification = values[2].parse::<i16>()
                    .map_err(|_| Error::new(ErrorKind::InvalidData, format!("Invalid font justification: {}", values[3])))?
                    .into();
            }

            if values.len() >= 6 {
                color = Some(Color::parse_rgb_values(&values[3..6])?);
            }

            return Ok(PrintData {
                index,
                colorindex,
                justification,
                color
            });
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Invalid font format: \"{}\"", value.to_string())))
    }
}
