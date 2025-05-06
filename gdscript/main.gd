extends Node2D

func _init() -> void:
    GameManager.configuration_directory = "res://mugen-data"
    GameManager.connect("state_changed", self.on_state_changed)

func _physics_process(_delta: float) -> void:
    GameManager.update()

func on_state_changed(state) -> void:
    print("State changed: ", state)
    if GameManager.error_message != "":
        print("Error: ", GameManager.error_message)
