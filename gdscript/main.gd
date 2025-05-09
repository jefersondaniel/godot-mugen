extends Node2D

var TitleScreen = preload("res://gdscript/screens/title_screen.gd")

var current_screen: Node2D

func _init() -> void:
    GameManager.configuration_directory = "res://mugen-data"
    GameManager.connect("state_changed", self.on_state_changed)

func _physics_process(_delta: float) -> void:
    GameManager.update()

func on_state_changed(state) -> void:
    print("State changed: ", state)
    if GameManager.error_message != "":
        print("Error: ", GameManager.error_message)
        return
    if state == "TitleScreen":
        show_screen(TitleScreen.new())

func show_screen(screen: Node2D) -> void:
    if current_screen:
        remove_child(current_screen)
    current_screen = screen
    add_child(screen)
