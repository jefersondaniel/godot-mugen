extends Node2D

var TitleScreen = load('res://source/gdscript/nodes/screens/title_screen.gd')
var SelectScreen = load('res://source/gdscript/nodes/screens/select_screen.gd')
var VsScreen = load('res://source/gdscript/nodes/screens/vs_screen.gd')
var FightScreen = load('res://source/gdscript/nodes/screens/fight_screen.gd')
var current_screen = null
var routes: Dictionary = {}
var current_route: Object

signal on_route(route, payload)

class Route:
    var name: String
    var transitions: Dictionary

    func _init(name: String):
        self.name = name
        self.transitions = {}

    func add_transition(route: Route, event: String):
        if transitions.has(event):
            push_error("transition already existis: %s" % [event])
            return
        transitions[event] = route

func _ready():
    var title_route = add_route("title")
    var training_selection_route = add_route("training_selection")
    var vs_route = add_route("vs")
    var fight_route = add_route("fight")

    vs_route.add_transition(fight_route, "done")
    title_route.add_transition(training_selection_route, constants.MENU_TRAINING)
    training_selection_route.add_transition(vs_route, "done")

    connect("on_route", self, "on_route_change")
    # start(title_route)
    start(fight_route)

func handle_menu_action(action):
    trigger(action.id, action)

func handle_done():
    trigger("done")

func on_route_change(route, payload = null):
    var store = constants.container["store"]

    match route.name:
        "title":
            var screen = TitleScreen.new()
            screen.connect("menu_action", self, "handle_menu_action")
            set_current_screen(screen)
        "training_selection":
            show_select_screen(payload)
        "vs":
            var screen = VsScreen.new()
            screen.connect("done", self, "handle_done")
            set_current_screen(screen)
        "fight":
            var screen = FightScreen.new()
            screen.connect("done", self, "handle_done")
            set_current_screen(screen)
        _:
            push_error("unhandled route: %s" % [route.name])

func show_select_screen(action):
    var store = constants.container["store"]

    store.select_requests = []
    store.character_select_result = []
    store.stage_select_result = []

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
    screen.connect("done", self, "handle_done")
    set_current_screen(screen)

func set_current_screen(screen):
    if current_screen:
        remove_child(current_screen)
        current_screen.queue_free()
    current_screen = screen
    add_child(screen)

func start(initial_route: Route, payload = null):
    set_route(initial_route, payload)

func add_route(name: String) -> Route:
    if routes.has(name):
        push_warning("route already exists: %s" % [name])

    var route = Route.new(name)
    routes[name] = route
    return route

func trigger(event: String, payload = null):
    var new_route = current_route.transitions.get(event, null)

    if not new_route:
        push_error("invalid route transition: %s, route: %s" % [event, current_route.name])
        return

    set_route(new_route, payload)

func set_route(route, payload = null):
    current_route = route
    emit_signal("on_route", current_route, payload)
