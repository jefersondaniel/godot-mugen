extends Node2D

var AnimationSprite = load("res://source/gdscript/nodes/sprite/animation_sprite.gd")
var HudText = load("res://source/gdscript/nodes/fight/hud_text.gd")

var fight_configuration = null
var component = null
var text_replace = null
var label = null
var animation_sprite = null
var ticks: int = 0

func _init(fight_configuration, component, text_replace):
  self.fight_configuration = fight_configuration
  self.component = component
  self.text_replace = text_replace

func _ready():
  if animation_sprite:
    animation_sprite.set_process(false)

func setup():
  # TODO: Handle spr, facing, vfacing, scale, layerno

  ticks = component.displaytime

  if component.text:
    label = HudText.new()
    label.setup(component, 0, text_replace)
    add_child(label)
  elif component.anim >= 0:
    var animations = {}
    animations[component.anim] = fight_configuration.animations[component.anim]
    animation_sprite = AnimationSprite.new(fight_configuration.sprite_bundle, animations)
    animation_sprite.change_anim(component.anim)
    if component.offset != Vector2(-1, -1):
      animation_sprite.position = component.offset
    add_child(animation_sprite)

func update_tick():
  if animation_sprite:
    animation_sprite.handle_tick()
  ticks = ticks - 1

func is_finished():
  if animation_sprite and component.displaytime <= 0:
    return animation_sprite.get_time_from_the_end() >= 0

  return ticks <= 0
