extends Node2D

var Fight = load("res://source/gdscript/nodes/fight/fight.gd")
var Team = load("res://source/gdscript/nodes/fight/team.gd")
var UserCommandManager = load('res://source/native/user_command_manager.gdns')
var AiCommandManager = load("res://source/gdscript/nodes/character/ai_command_manager.gd")
var CharacterLoader = load("res://source/gdscript/loaders/character_loader.gd").new()
var StageLoader = load("res://source/gdscript/loaders/stage_loader.gd").new()
var Stage = load("res://source/gdscript/nodes/stage.gd")

signal done

var kernel: Object
var store: Object
var fight = null
var stage = null

func _init():
  setup_fight()

func setup_fight():
  stage = load_stage("res://data/stages/kfm.def")

  fight = Fight.new()
  fight.set_stage(stage)

  var character1 = load_character(1, "res://data/chars/kfm/kfm.def", 0)
  fight.set_team(1, Team.new(constants.TEAM_SIDE_LEFT, character1))

  var character2 = load_character(2, "res://data/chars/kfm/kfm.def", 3)
  fight.set_team(2, Team.new(constants.TEAM_SIDE_RIGHT, character2))

  add_child(fight)

func _physics_process(_delta: float):
  fight.update_tick()

func load_character(index: int, path: String, palette: int):
  var command_manager = UserCommandManager.new()
  command_manager.set_input_prefix('P%s_' % [index])
  command_manager.set_constants(constants)
  var character = CharacterLoader.load(path, palette, command_manager)
  return character

func load_ai(path: String, palette):
    var command_manager = AiCommandManager.new()
    var character = CharacterLoader.load(path, palette, command_manager)
    return character

func load_stage(path: String):
    return StageLoader.load(path)
