extends "res://source/gdscript/system/state.gd"

var ShowRoundNumberState = load("res://source/gdscript/nodes/fight/states/show_round_number.gd")

var fight_ref: WeakRef
var ticks: int = 0

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  if should_skip_intro():
    return

  var fight = fight_ref.get_ref()

  for character in fight.get_active_characters():
    character.ctrl = 0
    character.reset_state()
    character.change_anim(constants.STATE_STANDING)

func update_tick():
  var fight = fight_ref.get_ref()

  if should_skip_intro():
    return ShowRoundNumberState.new(fight)

  ticks += 1

func should_skip_intro():
  # TODO: Implement skip intro
  return false
