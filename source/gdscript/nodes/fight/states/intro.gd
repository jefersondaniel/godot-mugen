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

  fight.roundstate = constants.ROUND_STATE_INTRO

  for character in fight.get_active_characters():
    character.ctrl = 0

func update_tick():
  var fight = fight_ref.get_ref()

  if should_skip_intro():
    return ShowRoundNumberState.new(fight)

  ticks += 1

func should_skip_intro():
  var fight = fight_ref.get_ref()
  if not fight.check_assert_special(constants.ASSERTION_INTRO):
    return true
  return false
