use enumflags2::make_bitflags;

use crate::{enumerations::BackgroundLayer, regex::{RegEx, RegExFlags}, sprite::blending::Blending, text::text_section::TextSection, types::{Rect2, Vector2}};

#[derive(Clone, Debug)]
pub struct BaseBackground {
    pub id: i32,
    pub name: String,
    /**
     * Specifies the background element's starting position with respect to the top
     * center of the screen. Positive x values go right; positive y values go down.
     * The values are given in stage units, which correspond to pixel units in typical
     * use. Defaults to 0,0.
     */
    pub startlocation: Vector2,
    /**
     * Specifies how many pixels the background element should scroll for each pixel
     * of camera movement in the horizontal and vertical directions, respectively.
     * Setting delta=1,1 will cause the background element to move at the same speed
     * as the camera. 1,1 is an appropriate value for the ground under the characters'
     * feet. For elements off in the distance, use smaller values of delta to create
     * the illusion of depth. Similarly, elements in the foreground (layerno = 1)
     * should usually be given deltas larger than 1. Defaults to 1,1.
     */
    pub delta: Vector2,
    /**
     * Specifies if the background element is to be repeated ("tiled") in the horizontal
     * and/or vertical directions, respectively. A value of 0 specifies no tiling,
     * a value of 1 specifies infinite tiling, and any value greater than 1 will cause the
     * element to tile that number of times. If this line is omitted, no tiling will be performed.
     */
    pub tiling: Vector2,
    /**
     * If tiling is enabled, this line specifies the space to put between separate instances
     * of the tile in the horizontal and vertical directions, respectively. There is no effect
     * if tiling is not enabled. tilespacing defaults to 0,0.
     */
    pub tilingspacing: Vector2,
    /**
     * Specifies initial x- and y-velocities for the background element (these default to 0).
     * This functionality is also subsumed by the VelSet background controller.
     */
    pub velocity: Vector2,
    /**
     * If mask is set to 1, color 0 of the sprite will not be drawn. This is used in drawing
     * objects which are not rectangular in shape. For performance reasons, mask should be
     * set to 0 when not needed. This parameter is ignored for RGB sprites. Defaults to 0
     * normally. For historical reasons, mask will default to 1 if the trans parameter is
     * set to add or sub.
     */
    pub masking: bool,
    /*
       If layer is 0, the background element will be drawn behind the characters.
       If layer is 1, the element will be drawn in front of the characters. Within
       each layer, background elements are drawn back-to-front in the order they
       appear in the DEF file. Defaults to 0.
    */
    pub layer: BackgroundLayer,
    /**
     * Specifies the type of transparency blending to perform on the sprite. Transparency
     * modes are default, none, add, sub. Respectivelty, these specify default behavior,
     * no transparency, color addition and color subtraction. default and none both cause
     * non-animated elements to be drawn without any tranparency blending. For animated
     * background elements, default will use anim-specific transparency while other values
     * of trans will override the transparency flags in the anim. If add is specified, the
     * alpha parameter may be used to control the blending. Defaults to default.
     *
     * Note: If mugenversion is less than 1.0, none will behave the same as default for animated elements.
     */
    pub blending: Blending,
    pub drawrect: Option<Rect2>,
}

impl BaseBackground {
    pub fn from_text_section(section: &TextSection) -> Self {
        let mut drawrect: Option<Rect2> = section.get_attribute("maskwindow");
        if drawrect.is_none() {
            drawrect = section.get_attribute("window");
        }

        Self {
            name: get_background_name(section),
            id: section.get_attribute_or("id", 0),
            startlocation: section.get_attribute_or_default("start"),
            delta: section.get_attribute_or("delta", Vector2::new(1.0, 1.0)),
            tiling: section.get_attribute_or_default("tile"),
            tilingspacing: section.get_attribute_or_default("tilespacing"),
            velocity: section.get_attribute_or_default("velocity"),
            masking: section.get_attribute_or("mask", false),
            layer: section.get_attribute_or("layerno", BackgroundLayer::Back),
            blending: section.get_attribute_or_default("trans"),
            drawrect,
        }
    }

    pub fn has_tiling(&self) -> bool {
        self.tiling != Vector2::new(0.0, 0.0)
    }
}

fn get_background_name(textsection: &TextSection) -> String {
    let titleregex = RegEx::new(r".*BG\s*(\S.*)", make_bitflags!(RegExFlags::{IgnoreCase}));
    if let Some(matches) = titleregex.search(&textsection.title) {
        return matches.get_string(1);
    }
    "".to_string()
}