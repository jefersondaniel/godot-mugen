extends Object

var is_active: bool = false
var is_target_bind: bool = false
var facing_flag: int = 0
var offset: Vector2 = Vector2(0, 0)
var time: int = 0
var character_ref: WeakRef
var bind_character_ref: WeakRef

func _init(_character):
    character_ref = weakref(_character)

func get_character():
    return character_ref.get_ref()

func get_bind_character():
    return bind_character_ref.get_ref()

func reset():
    time = 0
    offset = Vector2(0, 0)
    facing_flag = 0
    bind_character_ref = weakref(null)
    is_active = false
    is_target_bind = false

func update():
    if is_active and (time == -1 or time > 0) and check_helper():
        if time > 0:
            time = time - 1
        bind()
    else:
        reset()

func check_helper():
    var bind_character = get_bind_character()
    if not is_active:
        return false
    if bind_character and bind_character.is_helper():
        if bind_character.remove_check():
            reset()
            return false
    return true

func setup(_bind_character, _offset: Vector2, _time: int, _facing_flag: int, _is_target_bind: bool):
    is_active = true
    bind_character_ref = weakref(_bind_character)
    offset = _offset
    time = _time
    facing_flag = _facing_flag
    is_target_bind = _is_target_bind

func bind():
    var character = get_character()
    var bind_character = get_bind_character()
    var old_position = character.position

    character.position = get_offset_location()
    character.velocity = bind_character.velocity
    character.acceleration = bind_character.acceleration

    if facing_flag > 0:
        character.is_facing_right = bind_character.is_facing_right
    elif facing_flag < 0:
        character.is_facing_right = not bind_character.is_facing_right

func get_offset_location() -> Vector2:
    var character = get_character()
    var bind_character = get_bind_character()

    var new_offset = offset * character.global_scale
    var output = bind_character.position

    output.y = output.y + new_offset.y

    if bind_character.is_facing_right:
        output.x = output.x + new_offset.x
    else:
        output.x = output.x - new_offset.x

    return output
