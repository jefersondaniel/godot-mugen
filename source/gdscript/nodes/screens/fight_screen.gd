extends Node2D

var FightHud = load("res://source/gdscript/nodes/fight_hud.gd")
var UserCommandManager = load("res://source/gdscript/nodes/character/user_command_manager.gd")
var AiCommandManager = load("res://source/gdscript/nodes/character/ai_command_manager.gd")
var CharacterLoader = load("res://source/gdscript/loaders/character_loader.gd").new()
var StageLoader = load("res://source/gdscript/loaders/stage_loader.gd").new()
var Fight = load("res://source/gdscript/nodes/fight.gd")
var Stage = load("res://source/gdscript/nodes/stage.gd")

signal done

var kernel: Object
var store: Object
var fight = null
var stage = null

func _init():
  kernel = constants.container["kernel"]
  store = constants.container["store"]

  setup_fight()
  setup_hud()

func setup_hud():
  var fight_configuration = kernel.get_fight_configuration()
  var fight_hud = FightHud.new(fight_configuration, kernel)
  add_child(fight_hud)

func setup_fight():
  stage = load_stage("res://data/stages/kfm.def")
  fight = Fight.new()
  fight.set_stage(stage)

  var character1 = load_character(1, "res://data/chars/kfm/kfm.def", 0)
  fight.add_character(character1, 1)
  var character2 = load_ai("res://data/chars/kfm/kfm.def", 3)
  fight.add_character(character2, 2)

  add_child(fight)

func _physics_process(_delta: float):
  stage.update_tick()
  fight.update_tick()

func load_character(index: int, path: String, palette: int):
  var command_manager = UserCommandManager.new('P%s_' % [index])
  var character = CharacterLoader.load(path, palette, command_manager)
  return character

func load_ai(path: String, palette):
    var command_manager = AiCommandManager.new()
    var character = CharacterLoader.load(path, palette, command_manager)
    return character

func load_stage(path: String):
    return StageLoader.load(path)
