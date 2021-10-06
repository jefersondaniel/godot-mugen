extends Node2D

var custom_rect setget set_custom_rect, get_custom_rect

func get_custom_rect():
  return custom_rect

func set_custom_rect(value: Rect2):
  if custom_rect != value:
    custom_rect = value
    update()

func _draw():
  if custom_rect:
    VisualServer.canvas_item_set_custom_rect(get_canvas_item(), true, custom_rect)
    VisualServer.canvas_item_set_clip(get_canvas_item(), true)
  else:
    VisualServer.canvas_item_set_clip(get_canvas_item(), false)
