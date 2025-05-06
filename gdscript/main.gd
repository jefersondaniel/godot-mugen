extends Node2D

func _init() -> void:
    GameManager.configuration_directory = "res://mugen-data"

func _process(_delta: float) -> void:
    GameManager.update()