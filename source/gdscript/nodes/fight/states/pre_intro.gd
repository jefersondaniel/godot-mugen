extends "res://source/gdscript/system/state.gd"

var IntroState = load("res://source/gdscript/nodes/fight/states/intro.gd")

var fight_ref: WeakRef
var ticks: int = 0

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  var fight = fight_ref.get_ref()
  var stage_definition = fight.stage.definition

  fight.remaining_time = constants.ROUND_TIME
  fight.roundstate = constants.ROUND_STATE_PRE_INTRO

  for character in fight.get_active_characters():
    character.reset_round_state()

    if character.team_number == 1:
      character.set_facing_right(stage_definition.player_p1facing == 1)
    else:
      character.set_facing_right(stage_definition.player_p2facing == 1)

    character.change_state(constants.STATE_INITIALIZE)

func update_tick():
  var fight = fight_ref.get_ref()

  ticks += 1

  if ticks > fight.configuration.round_info.start_waittime:
    return IntroState.new(fight)
