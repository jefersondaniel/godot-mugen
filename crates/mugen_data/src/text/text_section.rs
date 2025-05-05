use std::io::{ErrorKind,Error};
use log::warn;
use crate::attribute_value::{AttributeValue, ParseAttributeValue};

#[derive(Clone)]
pub struct TextSection {
    pub title: String,
    pub lines: Vec<AttributeValue>,
    pub parsedlines: Vec<(String, AttributeValue)>,
}

impl TextSection {
    pub fn new(
        title: String,
        lines: Vec<AttributeValue>,
        parsedlines: Vec<(String, AttributeValue)>,
    ) -> Self {
        TextSection {
            title: title,
            lines: lines,
            parsedlines: parsedlines,
        }
    }

    pub fn has_attribute(&self, key: &String) -> bool {
        if let Some(_) = self.get_attribute::<AttributeValue>(key) {
            return true
        }

        false
    }

    pub fn get_attribute<T: ParseAttributeValue>(&self, key: &str) -> Option<T> {
        for (data_key, data_value) in self.parsedlines.iter() {
            if key.to_lowercase() == data_key.to_lowercase() {
                let result = T::parse_attribute_value(data_value.clone());

                if let Err(error) = result {
                    warn!("{}", error);
                } else {
                    return result.ok();
                }

                break;
            }
        }

        None
    }

    pub fn get_attribute_or<T: ParseAttributeValue>(&self, key: &str, default: T) -> T {
        match self.get_attribute(key) {
            Some(value) => T::from(value),
            None => default,
        }
    }

    pub fn get_attribute_or_default<T: Default + ParseAttributeValue>(&self, key: &str) -> T {
        match self.get_attribute::<T>(key) {
            Some(value) => value,
            None => T::default(),
        }
    }

    pub fn get_attribute_or_fail<T: Default + ParseAttributeValue>(&self, key: &str) -> Result<T, Error> {
        match self.get_attribute::<T>(key) {
            Some(value) => Ok(value),
            None => Err(Error::new(ErrorKind::InvalidData, format!("Missing attribute: {}", key))),
        }
    }
}
