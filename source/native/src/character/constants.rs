use gdnative::prelude::*;

#[derive(Default)]
pub struct Constants {
    pub all_direction_keys: i64,
    pub input_state_down: i64,
    pub input_state_pressed: i64,
    pub input_state_released: i64,
    pub input_state_up: i64,
    pub key_modifier_ban_other_input: i64,
    pub key_modifier_detect_as_4way: i64,
    pub key_modifier_must_be_held: i64,
    pub key_direction_f: i64,
    pub key_direction_b: i64,
    pub key_direction_u: i64,
    pub key_direction_d: i64,
    pub key_a: i64,
    pub key_b: i64,
    pub key_c: i64,
    pub key_x: i64,
    pub key_y: i64,
    pub key_z: i64,
    pub key_s: i64,
}

impl From<&Variant> for Constants {
    fn from(variant: &Variant) -> Self {
        let object_ref = variant.try_to_object::<Object>();

        if object_ref.is_none() {
            godot_error!("invalid constants value");
            return Self::default();
        }

        let object = unsafe { object_ref.expect("invalid object ref").assume_safe() };

        Constants {
            all_direction_keys: i64::from_variant(&object.get("ALL_DIRECTION_KEYS")).unwrap(),
            input_state_down: i64::from_variant(&object.get("INPUT_STATE_DOWN")).unwrap(),
            input_state_pressed: i64::from_variant(&object.get("INPUT_STATE_PRESSED")).unwrap(),
            input_state_released: i64::from_variant(&object.get("INPUT_STATE_RELEASED")).unwrap(),
            input_state_up: i64::from_variant(&object.get("INPUT_STATE_UP")).unwrap(),
            key_modifier_ban_other_input: i64::from_variant(&object.get("KEY_MODIFIER_BAN_OTHER_INPUT")).unwrap(),
            key_modifier_detect_as_4way: i64::from_variant(&object.get("KEY_MODIFIER_DETECT_AS_4WAY")).unwrap(),
            key_modifier_must_be_held: i64::from_variant(&object.get("KEY_MODIFIER_MUST_BE_HELD")).unwrap(),
            key_direction_f: i64::from_variant(&object.get("KEY_F")).unwrap(),
            key_direction_b: i64::from_variant(&object.get("KEY_B")).unwrap(),
            key_direction_u: i64::from_variant(&object.get("KEY_U")).unwrap(),
            key_direction_d: i64::from_variant(&object.get("KEY_D")).unwrap(),
            key_a: i64::from_variant(&object.get("KEY_a")).unwrap(),
            key_b: i64::from_variant(&object.get("KEY_b")).unwrap(),
            key_c: i64::from_variant(&object.get("KEY_c")).unwrap(),
            key_x: i64::from_variant(&object.get("KEY_x")).unwrap(),
            key_y: i64::from_variant(&object.get("KEY_y")).unwrap(),
            key_z: i64::from_variant(&object.get("KEY_z")).unwrap(),
            key_s: i64::from_variant(&object.get("KEY_s")).unwrap(),
        }
    }
}
