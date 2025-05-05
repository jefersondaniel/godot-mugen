use std::{collections::HashMap, io::{Error, ErrorKind}};

use enumflags2::{make_bitflags, BitFlags};
use log::warn;

use crate::{attribute_value::AttributeValue, enumerations::{ClsnType, SpriteEffects}, regex::{RegEx, RegExFlags}, sprite::{blending::Blending, sprite_id::SpriteId}, text::{text_file::TextFile, text_section::TextSection}, types::{Rect2, Vector2}};

use super::{animation::{Animation, AnimationElement}, clns::Clsn};

#[derive(Default, Debug, Clone)]
pub struct Animations {
    animations: HashMap<i32, Animation>
}

struct AnimationFileRegEx {
    animation_title: RegEx,
    clsn: RegEx,
    clsn_line: RegEx,
    element: RegEx
}

impl Animations {
    pub fn from_text_file(text_file: &TextFile) -> Result<Self, Error> {
        let animation_file_regex = AnimationFileRegEx {
            animation_title: RegEx::new(r"^\s*begin action\s+(-?\d+)(,.+)?\s*$", make_bitflags!(RegExFlags::{IgnoreCase})),
            clsn: RegEx::new(r"clsn([12])(default)?:\s*(\d+)", make_bitflags!(RegExFlags::{IgnoreCase})),
            clsn_line: RegEx::new(r"clsn([12])?\[(-?\d+)\]\s*=\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)", make_bitflags!(RegExFlags::{IgnoreCase})),
            element: RegEx::new(r"\s*,\s*", make_bitflags!(RegExFlags::{IgnoreCase})),
        };
        let mut animations = HashMap::new();

        for section in text_file.sections.iter() {
            let animation_result = create_animation(section, &animation_file_regex);

            match animation_result {
                Ok(animation) => {
                    if !animations.contains_key(&animation.number) {
                        animations.insert(animation.number, animation);
                    } else {
                        warn!("Invalid duplicated animation: {}", section.title)
                    }
                },
                Err(error) => {
                    if error.kind() != ErrorKind::Other {
                        warn!("{}", error);
                    }
                }
            }
        }

        Ok(Self{ animations })
    }

    pub fn get_animation(&self, number: i32) -> Option<&Animation> {
        self.animations.get(&number)
    }
}


fn create_animation(section: &TextSection, regex: &AnimationFileRegEx) -> Result<Animation, Error> {
    let title_match = regex.animation_title.search(&section.title).ok_or_else(|| Error::new(ErrorKind::Other, "No match".to_string()))?;

    let animation_number = title_match.get_i32(1).ok_or_else(|| Error::new(ErrorKind::InvalidData, "Invalid animation number".to_string()))?;

    let mut loopstart = 0;
    let mut starttick = 0;
    let mut elements = Vec::<AnimationElement>::new();

    let mut loading_type1 = Vec::<Clsn>::new();
    let mut loading_type2 = Vec::<Clsn>::new();
    let mut default_type1 = Vec::<Clsn>::new();
    let mut default_type2 = Vec::<Clsn>::new();

    let mut loaddefault = false;
    let mut loadtype = ClsnType::None;
    let mut loadcount = 0;

    for line in &section.lines {
        let line_string = line.to_string();

        if loadcount > 0 {
            let clsn_option = create_clsn(line, loadtype, regex);

            if let Some(clsn) = clsn_option {
                if loaddefault {
                    if loadtype == ClsnType::Type1Attack {
                        default_type1.push(clsn);
                    }
                    if loadtype == ClsnType::Type2Normal {
                        default_type2.push(clsn);
                    }
                } else {
                    if loadtype == ClsnType::Type1Attack {
                        loading_type1.push(clsn);
                    }
                    if loadtype == ClsnType::Type2Normal {
                        loading_type2.push(clsn);
                    }
                }
            } else {
                warn!("Could not create Clsn from line: {}", line.to_string());
            }

            loadcount = loadcount - 1;
            continue;
        }

        let clsnmatch_option = regex.clsn.search(&line_string);

        if let Some(clsn_match) = clsnmatch_option {
            let mut clsntype = ClsnType::None;

            if clsn_match.get_string(1) == "1" {
                clsntype = ClsnType::Type1Attack;
            }

            if clsn_match.get_string(1) == "2" {
                clsntype = ClsnType::Type2Normal;
            }

            let isdefault = clsn_match.get_string(2).to_lowercase() == "default";

            if isdefault {
                if clsntype == ClsnType::Type1Attack {
                    default_type1.clear();
                }
                if clsntype == ClsnType::Type2Normal {
                    default_type2.clear();
                }
            }

            loadcount = clsn_match.get_i32(3).unwrap_or_default();
            loaddefault = isdefault;
            loadtype = clsntype;
            continue;
        }

        if line.to_string().to_lowercase() == "loopstart" {
            loopstart = elements.len();
            continue;
        }

        let element_result = create_element(
            line,
            elements.len(),
            starttick,
            default_type1.clone(),
            default_type2.clone(),
            loading_type1.clone(),
            loading_type2.clone(),
            regex,
        );

        match element_result {
            Ok(element) => {
                if element.gameticks == -1 {
                    starttick = -1;
                } else {
                    starttick += element.gameticks;
                }

                elements.push(element.clone());
                loading_type1.clear();
                loading_type2.clear();
            },
            Err(error) => {
                warn!("Invalid animation element. Anim No: {}, Line: {:?}, Detail: {:?}", animation_number, line, error);
            }
        }
    }

    if elements.len() == 0 {
        return Err(Error::new(ErrorKind::InvalidData, format!("Invalid animation {}, no elements", animation_number)));
    }

    if loopstart == elements.len() {
        loopstart = 0;
    }

    Ok(Animation::new(
        animation_number,
        loopstart,
        elements
    ))
}

fn create_clsn(line: &AttributeValue, overridetype: ClsnType, regex: &AnimationFileRegEx) -> Option<Clsn> {
    if !line.compare("clsn", 0, 0, 4) {
        return None
    }

    let line_string = line.to_string();
    let clsn_match = regex.clsn_line.search(&line_string)?;

    let mut x1 = clsn_match.get_i32(3)?;
    let mut y1 = clsn_match.get_i32(4)?;
    let mut x2 = clsn_match.get_i32(5)?;
    let mut y2 = clsn_match.get_i32(6)?;

    if x1 > x2 {
        std::mem::swap(&mut x1, &mut x2);
    }

    if y1 > y2 {
        std::mem::swap(&mut y1, &mut y2);
    }

    Some(Clsn::new(overridetype, Rect2::new(
        Vector2::new(x1 as f32, y1 as f32),
        Vector2::new((x2 - x1) as f32, (y2 - y1) as f32))
    ))
}

fn create_element(
    line: &AttributeValue,
    elementid: usize,
    starttick: i32,
    default_type1: Vec<Clsn>,
    default_type2: Vec<Clsn>,
    loading_type1: Vec<Clsn>,
    loading_type2: Vec<Clsn>,
    regex: &AnimationFileRegEx
) -> Result<AnimationElement, Error> {
    let line_string = line.to_string();
    let elements = regex.element.split(&line_string).ok_or_else(|| Error::new(ErrorKind::Other, "No match"))?;

    if elements.len() < 5 {
        return Err(Error::new(ErrorKind::InvalidData, "Invalid animation element: Not enough parameters"));
    }

    let groupnumber = elements[0].to_string().parse::<i32>().unwrap_or(0);
    let imagenumber = elements[1].to_string().parse::<i32>().unwrap_or(0);
    let offset_x = elements[2].to_string().parse::<i32>().unwrap_or(0);
    let offset_y = elements[3].to_string().parse::<i32>().unwrap_or(0);
    let gameticks = elements[4].to_string().parse::<i32>().unwrap_or(0);
    let mut flip = BitFlags::empty();

    if elements.len() >= 6 {
        let flip_text = elements[5].to_lowercase();

        if flip_text.contains("h") {
            flip |= SpriteEffects::FlipHorizontally;
        }

        if flip_text.contains("v") {
            flip |= SpriteEffects::FlipVertically;
        }
    }

    let mut blending = Blending::default();

    if elements.len() >= 7 {
        blending = Blending::from(elements[6]);
    }

    let mut clsn = Vec::<Clsn>::new();
    clsn.extend(if loading_type1.len() != 0 { loading_type1.clone() } else { default_type1.clone() });
    clsn.extend(if loading_type2.len() != 0 { loading_type2.clone() } else { default_type2.clone() });

    let element = AnimationElement::new(
        elementid,
        gameticks,
        SpriteId::new(groupnumber as i16, imagenumber as i16),
        Vector2::new(offset_x as f32, offset_y as f32),
        flip,
        blending,
        starttick
    );

    Ok(element)
}
