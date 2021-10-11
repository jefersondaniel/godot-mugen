extends "res://source/gdscript/system/state.gd"

var RoundEndState = load("res://source/gdscript/nodes/fight/states/round_end.gd")

var fight_ref: WeakRef
var fight setget ,get_fight
var winner_team setget ,get_winner_team
var ticks: int = 0
var round_component_name: String = ""

func _init(fight):
  self.fight_ref = weakref(fight)

func activate():
  if self.winner_team:
    self.winner_team.win_history.append({
      'type': constants.VICTORY_TYPE_NORMAL,
      'perfect': self.winner_team.is_win_perfect
    })

    self.show_win_pose(self.winner_team)

    if self.winner_team.enemy_team.is_lose_time:
      self.show_lose_time_over_pose(self.winner_team.enemy_team)

    # Show name
  else:
    self.show_lose_time_over_pose(self.fight.team_1)
    self.show_lose_time_over_pose(self.fight.team_2)

  self.show_component()

func show_component():
  if not self.winner_team:
    show_round_component("draw")
    return

  # TODO: Support teammate
  show_round_component("win", self.winner_team.main_character.definition.display_name)

func show_round_component(name: String, text_replace = null):
  self.round_component_name = name
  self.fight.hud.show_round_component(name, text_replace)

func show_win_pose(team):
  for character in team.characters:
    character.change_state(constants.STATE_WIN_POSE)

func show_lose_time_over_pose(team):
  for character in team.characters:
    character.change_state(constants.STATE_LOSE_TIME_OVER_POSE)

func update_tick():
  ticks += 1
  if is_finished():
    return RoundEndState.new(self.fight)

func is_finished():
  var configuration = self.fight.configuration
  var hud = self.fight.hud

  if self.fight.assert_special(constants.ASSERTION_WINPOSE):
    return false

  return ticks > configuration.round_info.over_time or not hud.is_element_active(self.round_component_name)

func get_winner_team():
  if self.fight.team_1.is_win:
    return self.fight.team_1
  if self.fight.team_2.is_win:
    return self.fight.team_2
  return null

func get_fight():
  return self.fight_ref.get_ref()
