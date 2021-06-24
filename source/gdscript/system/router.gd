extends Node2D

var StateMachine = load('res://source/gdscript/system/state_machine.gd')
var TitleScreen = load('res://source/gdscript/nodes/screens/title_screen.gd')
var SelectScreen = load('res://source/gdscript/nodes/screens/select_screen.gd')
var current_screen = null
var state_machine = null
var store = null

func _ready():
    state_machine = StateMachine.new()

    var title_state = state_machine.add_state("title")

    var training_selection_state = state_machine.add_state("training_selection")
    title_state.add_transition(training_selection_state, constants.MENU_TRAINING)

    state_machine.connect("on_state", self, "on_state_change")
    state_machine.start(title_state)

func on_title_menu_action(action):
    state_machine.trigger(action.id, action)

func on_state_change(state, payload = null):
    var store = constants.container["store"]

    match state.name:
        "title":
            var screen = TitleScreen.new()
            screen.connect("on_menu_action", self, "on_title_menu_action")
            set_current_screen(screen)
        "training_selection":
            show_select_screen(payload)
        _:
            push_error("unhandled state: %s" % [state.name])

func show_select_screen(action):
    var store = constants.container["store"]

    store.select_requests = []
    store.select_results = []

    if action:
        store.fight_type = action.id
        store.fight_type_text = action.text

        if action.id == 'training':
            store.select_requests = [
                {
                    'input': 1,
                    'team': 1,
                    'role': 'player',
                },
                {
                    'input': 1,
                    'team': 2,
                    'role': 'player',
                },
            ]

    var screen = SelectScreen.new()
    set_current_screen(screen)

func set_current_screen(screen):
    if current_screen:
        remove_child(current_screen)
        current_screen.queue_free()
    current_screen = screen
    add_child(screen)
