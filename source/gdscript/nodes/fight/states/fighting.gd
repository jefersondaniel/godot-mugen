extends "res://source/gdscript/system/state.gd"

var fight_ref: WeakRef
var tick: int = 0

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  var fight = fight_ref.get_ref()
  fight.roundstate = constants.ROUND_STATE_FIGHT
  for character in fight.get_active_characters():
    character.ctrl = 1

func update_tick():
  var fight = fight_ref.get_ref()

  if tick % constants.TARGET_FPS == 0:
    fight.decrease_remaining_time()

  tick += 1
