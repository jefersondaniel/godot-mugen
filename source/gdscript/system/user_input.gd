class Controller:
    var prefix = null

    func _init(prefix):
        self.prefix = prefix

    func is_action_pressed(action):
        return Input.is_action_pressed(prefix + action)

    func is_action_just_pressed(action):
        return Input.is_action_just_pressed(prefix + action)

    func is_action_just_released(action):
        return Input.is_action_just_released(prefix + action)

    func is_select_just_pressed():
        return is_action_just_pressed("s") or is_action_just_pressed("x")

class MergedController:
    var controls: Array = []

    func _init(controls):
        self.controls = controls

    func is_action_pressed(action):
        for control in controls:
            if control.is_action_pressed(action):
                return true
        return false

    func is_action_just_pressed(action):
        for control in controls:
            if control.is_action_just_pressed(action):
                return true
        return false

    func is_action_just_released(action):
        for control in controls:
            if control.is_action_just_released(action):
                return true
        return false

    func is_select_just_pressed():
        return is_action_just_pressed("s") or is_action_just_pressed("x")

var p1 = Controller.new('P1_')
var p2 = Controller.new('P2_')
var any = MergedController.new([p1, p2])
