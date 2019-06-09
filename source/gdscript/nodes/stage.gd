extends Node

var CharacterLoader = load('res://source/gdscript/loaders/character_loader.gd').new()

var roundstate: int = 2 # 0: Pre-intro - screen fades in 1: Intro 2: Fight - players do battle 3: Pre-over - just a round is won or lost 4: Over - win poses
var gravity = Vector2(0, 0.35)
var ground_y = 400

func _init():
    var character = CharacterLoader.load('res://data/chars/kfm/kfm.def', 'P1_')

    character.stage = self
    character.position = Vector2(300, ground_y)

    self.add_child(character)
