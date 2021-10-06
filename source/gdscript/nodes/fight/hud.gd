extends CanvasLayer

var AnimationSprite = load("res://source/gdscript/nodes/sprite/animation_sprite.gd")
var ClipNode = load("res://source/gdscript/nodes/ui/clip_node.gd")
var HudComponent = load("res://source/gdscript/nodes/fight/hud_component.gd")
var HudText = load("res://source/gdscript/nodes/fight/hud_text.gd")
var UiLabel = load("res://source/gdscript/nodes/ui/label.gd")

var fight_configuration: Object
var kernel: Object
var sprite_bundle: Object
var debug_text: RichTextLabel
var round_components = {}
var time_label = null
var lifebar_range_map: Dictionary = {}
var powerbar_range_map: Dictionary = {}

func _init(fight_configuration, kernel):
  self.fight_configuration = fight_configuration
  self.kernel = kernel
  self.sprite_bundle = fight_configuration.sprite_bundle

  setup()

func setup():
  setup_lifebar()
  setup_powerbar()
  setup_face()
  setup_name()
  setup_time()
  # setup_combo()
  # setup_component(fight_configuration.round_info.draw)

func setup_lifebar():
  setup_lifebar_player(fight_configuration.lifebar.p1, 1)
  setup_lifebar_player(fight_configuration.lifebar.p2, 2)

func setup_lifebar_player(lifebar_data, playerno: int):
  var wrapper = Node2D.new()

  wrapper.position = lifebar_data.pos
  wrapper.add_child(create_background(lifebar_data.bg0))
  wrapper.add_child(create_background(lifebar_data.bg1))

  var mid = create_background(lifebar_data.mid)
  wrapper.add_child(mid)

  var front = create_background(lifebar_data.front)
  wrapper.add_child(front)

  lifebar_range_map[playerno] = {
    'range_x': lifebar_data.range_x,
    'mid': {
      'node': mid,
      'percent': 1.0,
    },
    'front': {
      'node': front,
      'percent': 1.0,
    },
  }

  add_child(wrapper)

func setup_powerbar():
  setup_powerbar_player(fight_configuration.powerbar.p1, 1)
  setup_powerbar_player(fight_configuration.powerbar.p2, 2)

func setup_powerbar_player(powerbar_data, playerno: int):
  var powerbar = Node2D.new()
  powerbar.position = powerbar_data.pos

  var counter_label = create_label(powerbar_data.counter)
  counter_label.set_text("3")

  powerbar.add_child(create_background(powerbar_data.bg0))
  powerbar.add_child(create_background(powerbar_data.bg1))
  var mid = create_background(powerbar_data.mid)
  powerbar.add_child(mid)
  var front = create_background(powerbar_data.front)
  powerbar.add_child(front)
  var counter = counter_label
  powerbar.add_child(counter_label)

  powerbar_range_map[playerno] = {
    'counter': counter,
    'range_x': powerbar_data.range_x,
    'mid': {
      'node': mid,
      'percent': 0.5,
    },
    'front': {
      'node': front,
      'percent': 0.2,
    },
  }

  add_child(powerbar)

func setup_face():
  setup_face_player(fight_configuration.face.p1)
  setup_face_player(fight_configuration.face.p2)
  
func setup_face_player(face_data):
  var face = Node2D.new()
  face.position = face_data.pos

  face.add_child(create_background(face_data.bg0))
  face.add_child(create_background(face_data.bg1))

  add_child(face)

func setup_name():
  setup_name_player(fight_configuration.name.p1)
  setup_name_player(fight_configuration.name.p2)

func setup_name_player(name_data):
  var name = Node2D.new()
  name.position = name_data.pos

  var name_label = create_label(name_data.name)
  name_label.set_text("Player Name")
  name.add_child(name_label)

  add_child(name)

func setup_combo():
  setup_combo_team(fight_configuration.combo.team1)
  setup_combo_team(fight_configuration.combo.team2)

func setup_combo_team(combo):
  var wrapper = Node2D.new()
  wrapper.position = combo.pos

  var counter_value = "1"
  var combo_text = combo.text.text.replace("%i", counter_value)

  if len(combo.counter.font):
    var counter = UiLabel.new()
    counter.set_text(counter_value)
    counter.set_font(kernel.get_fight_font(combo.counter.font))
    wrapper.add_child(counter)
    var text = create_label(combo.text, counter.get_text_width())
    text.set_text(combo_text)
    wrapper.add_child(text)
  else:
    var text = create_label(combo.text)
    text.set_text(combo_text)
    wrapper.add_child(text)

  add_child(wrapper)

func setup_time():
  var wrapper = Node2D.new()
  wrapper.position = fight_configuration.time.pos

  time_label = create_label(fight_configuration.time.counter)
  time_label.set_text("99")
  wrapper.add_child(time_label)

  add_child(wrapper)

func show_round_component(key: String):
  var definition = fight_configuration.round_info.get(key)
  var node = create_component(definition)

  if key in round_components:
    round_components[key]["node"].queue_free()

  round_components[key] = {
    "node": node,
    "definition": definition,
    "ticks": definition.displaytime
  }

  add_child(node)

func show_round_number(roundno: int):
  var key = "round"
  var definition = fight_configuration.round_info.get_round_component(roundno)
  var node = create_component(definition, String(roundno))

  if key in round_components:
    round_components[key]["node"].queue_free()

  round_components[key] = {
    "node": node,
    "definition": definition,
    "ticks": definition.displaytime
  }

  add_child(node)

func create_component(component, text_replace = null):
  var node = HudComponent.new(fight_configuration, component, text_replace)
  node.setup()
  return node

func create_background(bg_config):
  if len(bg_config.spr) == 0 and bg_config.anim == -1:
    return ClipNode.new()

  var wrapper = ClipNode.new()
  var sprite 
 
  if bg_config.anim >= 0:
    var animations = {}
    animations[bg_config.anim] = fight_configuration.animations[bg_config.anim]
    sprite = AnimationSprite.new(fight_configuration.sprite_bundle, animations)
    sprite.change_anim(bg_config.anim)
    sprite.set_facing_right(bg_config.facing == 1)
  else:
    sprite = fight_configuration.sprite_bundle.create_sprite(bg_config.spr, bg_config.facing)

  sprite.position = bg_config.offset
  wrapper.add_child(sprite)

  return wrapper

func create_label(label_data, padding: int = 0, text_replace = null):
  var node = HudText.new()
  node.setup(label_data, padding, text_replace)
  return node

func update_tick():
  var timeout_keys: Array = []

  for key in round_components:
    var component: Dictionary = round_components[key]
    component["node"].update_tick()
    if component["node"].is_finished():
      timeout_keys.append(key)

  for key in timeout_keys:
    round_components[key]["node"].queue_free()
    round_components.erase(key)

  for playerno in lifebar_range_map:
    var data = lifebar_range_map[playerno]
    var range_x = data["range_x"]

    lifebar_range_map[playerno]["mid"]["percent"] = lerp(
      lifebar_range_map[playerno]["mid"]["percent"],
      lifebar_range_map[playerno]["front"]["percent"],
      0.1
    )

    update_range(data["front"]["node"], range_x, data["front"]["percent"])
    update_range(data["mid"]["node"], range_x, data["mid"]["percent"])

  for playerno in powerbar_range_map:
    var data = powerbar_range_map[playerno]
    var range_x = data["range_x"]

    powerbar_range_map[playerno]["mid"]["percent"] = lerp(
      powerbar_range_map[playerno]["mid"]["percent"],
      powerbar_range_map[playerno]["front"]["percent"],
      0.1
    )

    update_range(data["front"]["node"], range_x, data["front"]["percent"])
    update_range(data["mid"]["node"], range_x, data["mid"]["percent"])

func is_element_active(key: String):
  return round_components.has(key)

func set_time_text(value: String):
  time_label.set_text(value)

func set_lifebar_percent(playerno: int, percent: float):
  lifebar_range_map[playerno]["front"]["percent"] = percent

func update_range(node: Node2D, range_value: PoolIntArray, percent: float = 1.0):
  var range_start: int = range_value[0]
  var range_end: int = range_value[1]
  var max_height: int = constants.WINDOW_SIZE.x
  
  if percent <= 0:
    node.custom_rect = Rect2(-1, -1, 0, 0)
    return

  if range_start < range_end:
    node.custom_rect = Rect2(
      Vector2(range_start, -max_height / 2),
      Vector2((range_end - range_start) * percent, max_height)
    )
  else:
    var full_size = range_start - range_end
    var expected_size = full_size * percent
    node.custom_rect = Rect2(
      Vector2(range_end + full_size - expected_size, -max_height / 2),
      Vector2(expected_size, max_height)
    )
