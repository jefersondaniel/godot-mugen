extends Node

var UserCommandManager = load('res://source/gdscript/nodes/user_command_manager.gd')
var AiCommandManager = load('res://source/gdscript/nodes/ai_command_manager.gd')
var CharacterLoader = load('res://source/gdscript/loaders/character_loader.gd').new()

var roundstate: int = 2 # 0: Pre-intro - screen fades in 1: Intro 2: Fight - players do battle 3: Pre-over - just a round is won or lost 4: Over - win poses
var gravity = Vector2(0, 0.50)
var ground_y = 400
var teams = {}

func _init():
    var player1 = create_player(1, 'res://data/chars/kfm/kfm.def', 0)
    add_player(player1, Vector2(200, ground_y), 1)

    var player2 = create_ai('res://data/chars/kfm/kfm.def', 3)
    add_player(player2, Vector2(400, ground_y), 2)

func create_player(index: int, path: String, palette: int):
    var command_manager = UserCommandManager.new('P%s_' % [index])
    var player = CharacterLoader.load(path, palette, command_manager)
    player.stage = self
    return player

func create_ai(path: String, palette: int):
    var command_manager = AiCommandManager.new()
    var player = CharacterLoader.load(path, palette, command_manager)
    player.stage = self
    return player

func add_player(player, position: Vector2, team: int):
    player.position = position
    player.team = team
    if teams.has(team) == false:
        teams[team] = []
    teams[team].append(player)
    self.add_child(player)

func get_nearest_enemy(player):
    var nearest_enemy = null
    var nearest_enemy_distance = 9999

    for team_id in teams:
        if team_id == player.team:
            continue

        for other in teams[team_id]:
            var distance: int = other.position.distance_to(player.position)
            if distance < nearest_enemy_distance:
                nearest_enemy_distance = distance
                nearest_enemy = other

    return nearest_enemy

func get_enemies(player):
    var results: Array = []

    for team_id in teams:
        if team_id == player.team:
            continue

        for other in teams[team_id]:
            results.push_back(other)

    return results
