
var team_number setget ,get_team_number
var team_side: String = constants.TEAM_SIDE_LEFT
var main_character = null
var characters setget ,get_characters
var active_characters setget ,get_active_characters
var fight setget set_fight,get_fight
var fight_ref: WeakRef

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
