extends Node

var Character = load('res://source/gdscript/entity/character.gd')

func _init():
	var character = Character.new('res://data/chars/kfm/kfm.def')
	character.position = Vector2(300, 300)
	self.add_child(character)
