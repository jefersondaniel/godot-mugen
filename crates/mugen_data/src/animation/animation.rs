use std::{fmt::Display, io::{Error, ErrorKind}};

use enumflags2::BitFlags;

use crate::{sprite::{sprite_id::SpriteId, blending::Blending}, types::Vector2, enumerations::SpriteEffects};

#[derive(Copy, Clone, Debug, PartialEq)]
pub struct AnimationElement {
    pub id: usize,
    pub gameticks: i32,
    pub sprite_id: SpriteId,
    pub offset: Vector2,
    pub flip: BitFlags<SpriteEffects>,
    pub blending: Blending,
    pub start_tick: i32,
}

impl AnimationElement {
    pub fn new(
        id: usize,
        gameticks: i32,
        sprite_id: SpriteId,
        offset: Vector2,
        flip: BitFlags<SpriteEffects>,
        blending: Blending,
        start_tick: i32,
    ) -> Self {
        AnimationElement {
            id: id,
            gameticks: gameticks,
            sprite_id: sprite_id,
            offset: offset,
            flip: flip,
            blending: blending,
            start_tick: start_tick,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Animation {
    pub number: i32,
    pub loopstart: usize,
    pub elements: Vec<AnimationElement>,
    pub totaltime: i32,
}

fn calculate_time(elements: &Vec<AnimationElement>) -> i32 {
    let mut time = 0;

    for element in elements.iter() {
        if element.gameticks == -1 {
            return -1;
        }

        time += element.gameticks;
    }

    time
}

impl Animation {
    pub fn new(
        number: i32,
        loopstart: usize,
        elements: Vec<AnimationElement>,
    ) -> Self {
        let totaltime = calculate_time(&elements);

        Animation {
            number: number,
            loopstart: loopstart,
            elements: elements,
            totaltime: totaltime,
        }
    }

    pub fn get_element_start_time(&self, elementnumber: usize) -> i32 {
        self.elements[elementnumber].start_tick
    }

    pub fn get_next_element(&self, elementnumber: usize) ->  Option<AnimationElement> {
        if elementnumber >= self.elements.len() {
            return None;
        }

        let next_element_number = elementnumber + 1;

        if next_element_number < self.elements.len() {
            return Some(self.elements[next_element_number]);
        }

        Some(self.elements[self.loopstart])
    }

    pub fn get_element_from_time(&self, time: i32) -> Result<AnimationElement, Error> {
        if time < 0 {
            return Err(Error::new(ErrorKind::InvalidData, format!("Invalid animation time: {}", time)));
        }

        let mut element_option = Some(self.elements[0]);
        let mut current_time = time;

        while let Some(element) = element_option {
            if element.gameticks == -1 {
                return Ok(element);
            }

            current_time -= element.gameticks;

            if current_time < 0 {
                return Ok(element);
            }

            element_option = self.get_next_element(element.id);
        }

        Err(Error::new(ErrorKind::InvalidData, format!("Unexpected error getting element from animation time: {}", time)))
    }
}

impl Display for AnimationElement {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&format!(
            "{}, {}, {}, {}, {}",
            self.sprite_id,
            format!("{}, {}", self.offset.x, self.offset.y),
            self.gameticks,
            format!(
                "{}{}",
                if self.flip.contains(SpriteEffects::FlipHorizontally) { "H" } else { "" },
                if self.flip.contains(SpriteEffects::FlipVertically) { "V" } else { "" }
            ),
            self.blending,
        ))
    }
}

impl Display for Animation {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&format!(
            "Action {}",
            self.number
        ))
    }
}
