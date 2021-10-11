var team_number setget ,get_team_number
var team_side: String = constants.TEAM_SIDE_LEFT
var main_character = null
var characters setget ,get_characters
var active_characters setget ,get_active_characters
var fight setget set_fight,get_fight
var fight_ref: WeakRef
var enemy_team setget set_enemy_team,get_enemy_team
var enemy_team_ref: WeakRef
var life setget ,get_life
var is_lose_ko setget ,get_is_lose_ko
var is_lose_time setget ,get_is_lose_time
var is_lose setget ,get_is_lose
var is_win_ko setget ,get_is_win_ko
var is_win_time setget ,get_is_win_time
var is_win setget ,get_is_win
var is_win_perfect setget ,get_is_win_perfect
var win_history: Array = []
var win_count setget ,get_win_count

func _init(team_side: String, main_character):
  self.team_side = team_side
  self.main_character = main_character
  self.main_character.team_number = self.team_number

func get_characters():
  return [main_character]

func get_active_characters():
  # TODO: Implement turn based combat
  return self.get_characters()

func get_team_number() -> int:
  return 1 if team_side == constants.TEAM_SIDE_LEFT else 2

func setup(fight):
  self.fight = fight

  self.reset_characters()

  for character in self.characters:
    character.team_number = self.team_number
    character.fight = self.fight
    fight.stage.add_player(character)

func reset_characters():
  var stage = self.fight.stage
  for character in self.characters:
    character.position = stage.get_starting_pos(self.team_number)
    if self.team_number == 1:
        character.set_facing_right(stage.definition.player_p1facing == 1)
    else:
        character.set_facing_right(stage.definition.player_p2facing == 1)

func set_fight(fight):
  self.fight_ref = weakref(fight)

func get_fight():
  return self.fight_ref.get_ref()

func set_enemy_team(team):
  enemy_team_ref = weakref(team)

func get_enemy_team():
  return enemy_team_ref.get_ref()

func get_life() -> int:
  # TODO: Suppor teams life
  return main_character.life

func get_is_lose_ko() -> bool:
  return self.life <= 0

func get_is_lose_time() -> bool:
  if self.is_lose_ko:
    return false
  if self.fight.remaining_time > 0:
    return false
  return self.enemy_team.life > self.life

func get_is_lose():
  return self.is_lose_ko or self.is_lose_time

func get_is_win_ko() -> bool:
  return not self.is_lose_ko and self.enemy_team.is_lose_ko

func get_is_win_time() -> bool:
  if self.is_win_ko:
    return false
  if self.fight.remaining_time >= 0:
    return false
  return self.enemy_team.life < self.life

func get_is_win() -> bool:
  return self.is_win_time or self.is_win_ko

func get_is_win_perfect() -> bool:
  if not self.is_win:
    return false
  # TODO: Add support to teammate
  return self.main_character.life == self.main_character.max_life

func get_win_count() -> int:
  return len(self.win_history)
