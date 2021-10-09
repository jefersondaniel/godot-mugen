extends "res://source/gdscript/system/state.gd"

var CombatOver = load("res://source/gdscript/nodes/fight/states/combat_over.gd")

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

  if is_finished():
    return CombatOver.new(fight)

  tick += 1

func is_finished():
  var fight = fight_ref.get_ref()

  return fight.remaining_time == 0 or fight.team_1.is_lose or fight.team_2.is_lose
