extends "res://source/gdscript/system/state.gd"

var PreIntroState = load("res://source/gdscript/nodes/fight/states/pre_intro.gd")

var fight_ref: WeakRef
var fight setget ,get_fight

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  var team_1 = self.fight.team_1
  var team_2 = self.fight.team_2
  var round_info = self.fight.configuration.round_info

  if team_1.win_count >= round_info.match_wins or team_2.win_count >= round_info.match_wins: 
    var router = constants.container["router"]
    router.trigger("done")
    return

  # TODO: Support arcade mode

  self.fight.increase_round()

  return PreIntroState.new(self.fight)

func get_fight():
  return self.fight_ref.get_ref()
