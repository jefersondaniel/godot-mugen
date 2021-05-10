extends Object

var attribute = null
var stateno: int = -1000
var time: int = 0
var force_air: int = 0
var is_active: bool = false

func setup(attribute, stateno, time, force_air):
    self.attribute = attribute
    self.stateno = stateno
    self.time = time
    self.force_air = force_air
    self.is_active = true

func reset():
    attribute = null
    stateno = -1000
    time = 0
    force_air = 0
    is_active = false

func handle_tick():
    if not is_active:
        return

    if time == -1:
        return

    if is_active and time > 0:
        time = time - 1
    else:
        reset()
