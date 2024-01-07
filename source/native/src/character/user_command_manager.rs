use gdnative::prelude::*;
use super::constants::Constants;
use std::collections::HashMap;

#[derive(Default, Copy, Clone)]
struct CommandElement {
    ticks: i64,
    modifier: i64,
    code: i64,
}

impl From<&Variant> for CommandElement {
    fn from(variant: &Variant) -> Self {
        let dict_ref = Dictionary::from_variant(variant);

        if !dict_ref.is_ok() {
            godot_error!("invalid command element value");
            return Self::default();
        }

        let dict = dict_ref.unwrap();

        CommandElement {
            ticks: i64::from_variant(&dict.get("ticks").unwrap_or(Variant::nil())).unwrap(),
            modifier: i64::from_variant(&dict.get("modifier").unwrap_or(Variant::nil())).unwrap(),
            code: i64::from_variant(&dict.get("code").unwrap_or(Variant::nil())).unwrap(),
        }
    }
}

#[derive(Default, Clone)]
struct Command {
    name: String,
    buffer_time: i64,
    time: i64,
    cmd: Vec<CommandElement>,
}

impl From<&Variant> for Command {
    fn from(variant: &Variant) -> Self {
        let dict_ref = Dictionary::from_variant(variant);

        if !dict_ref.is_ok() {
            godot_error!("invalid command element value");
            return Self::default();
        }

        let dict = dict_ref.unwrap();

        let variant_array = VariantArray::from_variant(&dict.get("cmd").unwrap_or(Variant::nil())).unwrap();
        let mut cmd: Vec<CommandElement> = Vec::new();
        for command_element_variant in variant_array.iter() {
            cmd.push(CommandElement::from(&command_element_variant));
        }


        Command {
            name: String::from_variant(&dict.get("name").unwrap_or(Variant::nil())).unwrap(),
            buffer_time: i64::from_variant(&dict.get("buffer_time").unwrap_or(Variant::nil())).unwrap(),
            time: i64::from_variant(&dict.get("time").unwrap_or(Variant::nil())).unwrap(),
            cmd: cmd,
        }
    }
}

#[derive(NativeClass, Default)]
#[inherit(Reference)]
pub struct UserCommandManager {
    input_prefix: String,
    constants: Constants,
    input_map: HashMap<String, i64>,
    buffer_size: usize,
    buffer_index: usize,
    buffer: Vec<i64>,
    command_countdown: HashMap<String, i64>,
    commands: Vec<Command>,
    #[property]
    active_commands: VariantArray,
    #[property]
    is_facing_right: bool,
}

#[methods]
impl UserCommandManager {
    pub fn new(
        _owner: &Reference
    ) -> Self {
        let buffer_size = 120;

        UserCommandManager {
            buffer_size: buffer_size,
            buffer_index: 0,
            buffer: vec![0; buffer_size],
            is_facing_right: true,
            ..Default::default()
        }
    }

    #[method]
    pub fn set_input_prefix(&mut self, input_prefix: String) {
        self.input_prefix = input_prefix;
    }

    #[method]
    pub fn set_constants(&mut self, variant: Variant) {
        self.constants = Constants::from(&variant);
        self.input_map.insert("U".to_string(), self.constants.key_direction_u);
        self.input_map.insert("D".to_string(), self.constants.key_direction_d);
        self.input_map.insert("a".to_string(), self.constants.key_a);
        self.input_map.insert("b".to_string(), self.constants.key_b);
        self.input_map.insert("c".to_string(), self.constants.key_c);
        self.input_map.insert("x".to_string(), self.constants.key_x);
        self.input_map.insert("y".to_string(), self.constants.key_y);
        self.input_map.insert("z".to_string(), self.constants.key_z);
        self.input_map.insert("s".to_string(), self.constants.key_s);
    }

    #[method]
    pub fn set_commands(&mut self, variant_array: VariantArray) {
        let mut commands: Vec<Command> = Vec::new();
        let mut command_countdown: HashMap<String, i64> = HashMap::new();
        for variant in variant_array.iter() {
            let command = Command::from(&variant);
            command_countdown.insert(command.name.to_string(), 0);
            commands.push(command);
        }
        self.commands = commands;
        self.command_countdown = command_countdown;
    }

    #[method]
    pub fn update(&mut self, in_hit_pause: bool) {
        self.update_input_buffer();
        self.update_command_countdown(in_hit_pause);
        self.check_commands(in_hit_pause);
        self.update_active_commands();
    }

    fn update_input_buffer(&mut self) {
        self.buffer_index += 1;

        if self.buffer_index >= self.buffer_size {
            self.buffer_index = 0;
        }

        let mut code = 0i64;

        let input = Input::godot_singleton();

        if Input::is_action_pressed(input, format!("{}F", self.input_prefix), false) {
            if self.is_facing_right {
                code += self.constants.key_direction_f;
            } else {
                code += self.constants.key_direction_b;
            }
        }

        if Input::is_action_pressed(input, format!("{}B", self.input_prefix), false) {
            if self.is_facing_right {
                code += self.constants.key_direction_b;
            } else {
                code += self.constants.key_direction_f;
            }
        }

        for action in vec!["U", "D", "a", "b", "c", "x", "y", "z", "s"].iter() {
            if Input::is_action_pressed(input, format!("{}{}", self.input_prefix, action), false) {
                code += self.input_map.get(&action.to_string()).unwrap_or(&0);
            }
        }

        self.buffer[self.buffer_index] = code;
    }

    fn update_command_countdown(&mut self, in_hit_pause: bool) {
        if in_hit_pause {
            return;
        }

        for value in self.command_countdown.values_mut() {
            *value = i64::max(*value - 1, 0);
        }
    }

    fn check_commands(&mut self, in_hit_pause: bool) {
        for command in self.commands.iter() {
            if !self.check_command(command) {
                continue;
            }

            let mut time = command.buffer_time;

            if in_hit_pause {
                time += 1;
            }

            self.command_countdown.insert(command.name.clone(), time);
        }
    }

    fn update_active_commands(&mut self) {
        let active_commands = VariantArray::new();
        for (key, value) in self.command_countdown.iter() {
            if *value <= 0 {
                continue;
            }
            active_commands.push(GodotString::from(key));
        }
        self.active_commands = active_commands.into_shared();
    }

    fn check_command(&self, command: &Command) -> bool {
        let mut element_index = command.cmd.len() - 1;
        let mut input_index = 0usize;

        while input_index != self.buffer_size {
            let match_index = self.scan_for_match(command, element_index, input_index);

            if match_index < 0 {
                return false
            }

            if element_index > 0 {
                if match_index > command.time {
                    return false;
                }

                element_index -= 1;
                input_index = match_index as usize;
            } else if element_index == 0 {
                return match_index <= command.time;
            } else {
                return false;
            }

            input_index += 1;
        }

        false
    }

    fn scan_for_match(&self, command: &Command, element_index: usize, input_index: usize) -> i64 {
        let element = command.cmd[element_index];
        let scan_length = usize::min(self.buffer_size, command.time as usize);

        for i in input_index..(input_index + scan_length) {
            if element_index == command.cmd.len() - 1 {
                if element.ticks == -1 {
                    if i != input_index {
                        return -1
                    }
                } else if i - 1 != input_index && i != input_index {
                    return -1;
                }
            }

            if self.element_match(&element, i) {
                if element_index < command.cmd.len() - 1 {
                    let next_element = command.cmd[element_index + 1];
                    let nothing_else = (next_element.modifier & self.constants.key_modifier_ban_other_input) != 0;
                    if nothing_else && !self.check_identical_input(input_index, i) {
                        continue
                    }
                }

                return i as i64
            }
        }

        -1
    }

    fn element_match(&self, element: &CommandElement, input_index: usize) -> bool {
        let state = self.get_input_state(input_index, element);
        let must_be_held = (element.modifier & self.constants.key_modifier_must_be_held) != 0;

        if must_be_held {
            return state == self.constants.input_state_down || state == self.constants.input_state_pressed;
        }

        if element.ticks != -1 {
            if input_index >= self.buffer_size {
                return false;
            }

            if input_index == 0 || self.get_input_state(input_index - 1, element) != self.constants.input_state_released {
                return false;
            }

            let mut hold_count = 1i64;

            for i in (input_index + 1)..self.buffer_size {
                if self.get_input_state(i, element) != self.constants.input_state_down {
                    break;
                }
                hold_count += 1;
            }

            if hold_count < element.ticks {
                return false;
            }
        } else if state != self.constants.input_state_pressed {
            return false;
        }

        true
    }

    fn get_input_value(&self, index: usize) -> i64 {
        let aux_buffer_index = self.buffer_index as i64;
        let aux_buffer_size = self.buffer_size as i64;
        let aux_index = index as i64;
        let aux_result = (aux_buffer_index - aux_index + aux_buffer_size) % aux_buffer_size;

        self.buffer[aux_result as usize]
    }

    fn get_input_state(&self, index: usize, element: &CommandElement) -> i64 {
        let current = self.get_input_value(index);
        let previous = if index != self.buffer_size -1 { self.get_input_value(index + 1) } else { 0i64 };
        let current_state = self.check_element_state(current, element);
        let previous_state = self.check_element_state(previous, element);

        if current_state {
            return if previous_state { self.constants.input_state_down } else { self.constants.input_state_pressed }
        }

        if previous_state { self.constants.input_state_released } else { self.constants.input_state_up }
    }

    fn check_identical_input(&self, start_index: usize, end_index: usize) -> bool {
        let input_value = self.get_input_value(start_index);

        for i in (start_index + 1)..end_index {
            if input_value != self.get_input_value(i) {
                return false;
            }
        }

        true
    }

    fn check_element_state(&self, input_code: i64, element: &CommandElement) -> bool {
        let use_4_way = (element.modifier & self.constants.key_modifier_detect_as_4way) != 0;
        let mut key_down = (input_code & element.code) == element.code;

        if key_down && !use_4_way {
            let input_direction = input_code & self.constants.all_direction_keys;
            let element_direction = element.code & self.constants.all_direction_keys;
            key_down = element_direction == 0 || (input_direction == element_direction);
        }

        key_down
    }
}
