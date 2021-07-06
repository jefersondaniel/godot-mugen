signal element_update(element, collisions)

var animations = null
var animation = null
var animation_finished = false
var animation_in_loop = false
var animation_time = 0
var element_switch_time = 0
var element = null # Element object
var is_foreign_animation: bool = false

func _init(animations):
    self.animations = animations

func set_local_animation(animation_number, element_index):
    animation = animations[animation_number]
    if not element_index:
        element_index = 0
    if element_index < 0 or element_index > animation.total_elements:
        printerr("Invalid element: %s" % [element_index])
        return
    is_foreign_animation = false
    set_animation(animation, animation.elements[element_index])

func set_foreign_animation(animation_manager, animation_number: int, element_index: int):
    var animation = animation_manager.animations[animation_number];
    if element_index < 0 or element_index > animation.total_elements:
        printerr("Invalid element on foreign animation: %s" % [element_index])
        return
    is_foreign_animation = true
    set_animation(animation, animation.elements[element_index])

func set_animation(_animation, _element = null):
    animation = _animation
    if _element:
        element = _element
    else:
        element = animation.elements[0]
    animation_finished = false
    animation_in_loop = false
    animation_time = animation.get_element_start_time(element.id)
    element_switch_time = element.ticks
    handle_element_update()

func has_animation(animation_number) -> bool:
    return animations.has(animation_number)

func handle_tick():
    if animation == null or element == null:
        return
    animation_finished = false
    animation_time += 1

    if element_switch_time == -1:
        return

    if element_switch_time > 1:
        element_switch_time -= 1
        return

    var next_element = animation.get_next_element(element.id)

    if next_element.id <= element.id:
        animation_in_loop = true
        animation_finished = true

    element = next_element
    element_switch_time = element.ticks

    handle_element_update()

func handle_element_update():
    var collisions = animation.get_collisions_from_element(element)
    emit_signal("element_update", element, collisions)
