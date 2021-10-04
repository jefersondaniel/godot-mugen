extends CanvasLayer

var AnimationSprite = load("res://source/gdscript/nodes/sprite/animation_sprite.gd")
var HudComponent = load("res://source/gdscript/nodes/fight/hud_component.gd")
var HudText = load("res://source/gdscript/nodes/fight/hud_text.gd")
var UiLabel = load("res://source/gdscript/nodes/ui/label.gd")

var fight_configuration: Object
var kernel: Object
var sprite_bundle: Object
var debug_text: RichTextLabel
var round_components = {}

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
  setup_lifebar_player(fight_configuration.lifebar.p1)
  setup_lifebar_player(fight_configuration.lifebar.p2)

func setup_lifebar_player(lifebar_data):
  var lifebar = Node2D.new()
  lifebar.position = lifebar_data.pos

  lifebar.add_child(create_background(lifebar_data.bg0))
  lifebar.add_child(create_background(lifebar_data.bg1))
  lifebar.add_child(create_background(lifebar_data.mid))
  lifebar.add_child(create_background(lifebar_data.front))

  add_child(lifebar)

func setup_powerbar():
  setup_powerbar_player(fight_configuration.powerbar.p1)
  setup_powerbar_player(fight_configuration.powerbar.p2)

func setup_powerbar_player(powerbar_data):
  var powerbar = Node2D.new()
  powerbar.position = powerbar_data.pos

  var counter_label = create_label(powerbar_data.counter)
  counter_label.set_text("3")

  powerbar.add_child(create_background(powerbar_data.bg0))
  powerbar.add_child(create_background(powerbar_data.bg1))
  powerbar.add_child(create_background(powerbar_data.mid))
  powerbar.add_child(create_background(powerbar_data.front))
  powerbar.add_child(counter_label)

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
  var time = Node2D.new()
  time.position = fight_configuration.time.pos

  var time_label = create_label(fight_configuration.time.counter)
  time_label.set_text("99")
  time.add_child(time_label)

  add_child(time)

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
    return Node2D.new()

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

  return sprite

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

func is_element_active(key: String):
  return round_components.has(key)
