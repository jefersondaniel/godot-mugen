extends Object

var identifier: int = 0
var loopstart: int = 0
var elements: Array = []
var collisions: Array = []
var total_elements: int = 0
var total_time: int = 0

func _init(_identifier, _loopstart, _elements, _collisions):
    identifier = _identifier
    loopstart = _loopstart
    elements = _elements
    collisions = _collisions
    total_elements = len(elements)
    total_time = 0
    for element in _elements:
        if element.ticks == -1:
            total_time = -1
            break
        total_time += element.ticks

func get_element_start_time(element_number):
    if element_number < 0 or element_number >= total_elements:
        printerr("Invalid element: %s" % [element_number])
        return

    return elements[element_number].start_tick

func calculate_total_time() -> int:
    var time: int = 0;

    for element in elements:
        if element.ticks == -1:
            return -1
        time += element.ticks

    return time

func get_next_element(element_number):
    if element_number < 0 or element_number >= total_elements:
        printerr("Invalid element: %s" % [element_number])
        return
    element_number += 1
    return elements[element_number] if element_number < total_elements else elements[loopstart]

func get_element_from_time(time: int):
    # TODO: Optmize performance here

    if time < 0:
        printerr("Invalid time: %s" % [time])
        return
    
    var element = elements[0]

    while element != null:
        if element.ticks == -1:
            return element
        time -= element.ticks
        if time < 0:
            return element
        element = get_next_element(element)

    printerr("Invalid get element from time")

func get_collisions_from_element(element):
    var custom_collision = {1: null, 2: null}
    var default_collision = {1: null, 2: null}

    for collision in collisions:
        if collision.element > element.id:
            break
        if collision.default:
            default_collision[collision.type] = collision
        if collision.element == element.id:
            custom_collision[collision.type] = collision

    return {
        1: custom_collision.get(1, default_collision[1]),
        2: custom_collision.get(2, default_collision[2]),
    }
