extends Node2D

var AnimationSprite = load("res://source/gdscript/nodes/sprite/animation_sprite.gd")

var fight_configuration: Object
var kernel: Object
var sprite_bundle: Object

func _init(fight_configuration, kernel):
  self.fight_configuration = fight_configuration
  self.kernel = kernel
  self.sprite_bundle = fight_configuration.sprite_bundle

  setup()

func setup():
  setup_lifebar()

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


