extends "res://source/gdscript/system/state.gd"

var WinPose = load("res://source/gdscript/nodes/fight/states/win_pose.gd")

var fight_ref: WeakRef
var ticks: int = 0
var win_type: String = ""

var WIN_TYPE_NONE = "None"
var WIN_TYPE_KO = "KO"
var WIN_TYPE_DOUBLEKO = "DoubleKO"
var WIN_TYPE_TIMEOUT = "TimeOut"
var WIN_TYPE_DRAW = "Draw"

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  var fight = fight_ref.get_ref()

  if fight.team_1.is_lose_time or fight.team_2.is_lose_time:
    win_type = WIN_TYPE_TIMEOUT
    fight.hud.show_round_component("to")
  elif fight.team_1.is_lose and fight.team_2.is_lose:
    win_type = WIN_TYPE_DOUBLEKO
    fight.hud.show_round_component("dko")
  elif fight.team_1.is_lose or fight.team_2.is_lose:
    win_type = WIN_TYPE_KO
    fight.hud.show_round_component("ko")
  else:
    win_type = WIN_TYPE_DRAW

func is_ko():
  return win_type == WIN_TYPE_KO or win_type == WIN_TYPE_DOUBLEKO

func update_tick():
  var fight = fight_ref.get_ref()
  var configuration = fight.configuration

  fight.is_slow_mode = is_ko() and not fight.assert_special(constants.ASSERTION_NOKOSLOW) and ticks < configuration.round_info.slow_time

  if ticks == configuration.round_info.over_waittime:
    for character in fight.get_active_characters():
      character.ctrl = 0

  if is_finished():
    return WinPose.new(fight)

  ticks += 1

func is_finished():
  var fight = fight_ref.get_ref()
  var configuration = fight.configuration

  if ticks < configuration.round_info.over_waittime:
    return false

  # Check if all character are ready
  for character in fight.get_active_characters():
    if character.life > 0:
      if character.stateno != constants.STATE_STANDING:
        return false
      continue
    if character.stateno != constants.STATE_HIT_LIE_DEAD or character.velocity != Vector2(0, 0):
      return false

  return ticks - configuration.round_info.over_waittime > configuration.round_info.win.time
