var HitAttribute = load('res://source/gdscript/nodes/character/hit_attribute.gd')

var attribute = null
var time: int = 0
var is_negation: bool = false
var is_active: bool = false

func handle_tick():
    if not self.is_active:
        return

    if is_active and time > 0:
        self.time = time - 1
    else:
        self.is_active = false

func setup(attribute, time: int, is_negation: bool):
    self.attribute = attribute
    self.time = time
    self.is_negation = is_negation
    self.is_active = true

func can_hit(other_attribute) -> bool:
    if not self.is_active:
        return true

    var result: bool = other_attribute.satisfy(self.attribute)

    if self.is_negation:
        return !result

    return result
