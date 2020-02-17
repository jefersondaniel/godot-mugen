extends Node

var UserCommandManager = load('res://source/gdscript/nodes/character/user_command_manager.gd')
var AiCommandManager = load('res://source/gdscript/nodes/character/ai_command_manager.gd')
var CharacterLoader = load('res://source/gdscript/loaders/character_loader.gd').new()
var StageLoader = load('res://source/gdscript/loaders/stage_loader.gd').new()
var Fight = load('res://source/gdscript/nodes/fight.gd')
var Stage = load('res://source/gdscript/nodes/stage.gd')

func _init():
    Engine.set_target_fps(constants.TARGET_FPS)

    var fight = Fight.new()

    var stage = load_stage("res://data/stages/kfm.def")

    fight.set_stage(stage)

    var character1 = load_character(1, 'res://data/chars/kfm/kfm.def', 0)
    fight.add_character(character1, 1)

    var character2 = load_ai('res://data/chars/kfm/kfm.def', 3)
    fight.add_character(character2, 2)

    self.add_child(fight)

func load_character(index: int, path: String, palette: int):
    var command_manager = UserCommandManager.new('P%s_' % [index])
    var character = CharacterLoader.load(path, palette, command_manager)
    return character

func load_ai(path: String, palette: int):
    var command_manager = AiCommandManager.new()
    var character = CharacterLoader.load(path, palette, command_manager)
    return character

func load_stage(path: String):
    return StageLoader.load(path)
