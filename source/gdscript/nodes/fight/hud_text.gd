extends Node2D

var UiLabel = load("res://source/gdscript/nodes/ui/label.gd")

var kernel = null
var label = null

func _init():
  kernel = constants.container["kernel"]

func setup(label_data, padding: int = 0, text_replace = null):
  label = UiLabel.new()
  var name_font = kernel.get_fight_font(label_data.font)
  var text = label_data.text

  if text_replace:
    text = text.replace("%i", text_replace)

  label.set_text(text)
  label.set_font(name_font)

  var offset: Vector2 = Vector2(0, 0)

  if label_data.offset != Vector2(-1, -1):
    offset = label_data.offset

  var padding_multiplier = 1 if name_font["alignment"] == 1 else -1
  if padding > 0:
    # Padding multiplier was applied only here because combo text seems to need this, but powerbar counter does not. Consider creating a special label type that handles offsets and multiple fonts.
    label.position = offset * padding_multiplier
    label.position.x += padding * padding_multiplier
  else:
    label.position = offset

  add_child(label)

func set_text(text):
  label.set_text(text)
