extends Node2D

var custom_rect = null

func _draw():
  if custom_rect:
    VisualServer.canvas_item_set_custom_rect(get_canvas_item(), true, custom_rect)
    VisualServer.canvas_item_set_clip(get_canvas_item(), true)
  else:
    VisualServer.canvas_item_set_clip(get_canvas_item(), false)
