extends Node2D

var UiLabel = load('res://source/gdscript/nodes/ui/label.gd')
var user_input = load('res://source/gdscript/system/user_input.gd').new()

var item_spacing: Vector2 = Vector2(0, 0)
var window_margins_y: Vector2 = Vector2(12, 8)
var window_visibleitems: int = 5
var default_font = null
var active_font = null
var actions: Array = []
var cursor_visible: int = 0
var cursor_box: Rect2 = Rect2(0, 0, 0, 0)
var cursor_offset: Vector2 = Vector2(0, 0)
var cursor_move_snd: Array = []
var cursor_done_snd: Array = []
var label_map: Dictionary = {}
var cursor = null
var cursor_texture = null
var selected_action_index: int = 0
var custom_rect = null
var scroller = null

class Cursor extends Node2D:
    var texture = null
    var size: Vector2 = Vector2(0, 0)

    func _init():
        var empty_image = Image.new()
        empty_image.create_from_data(1, 1, false, 5, PoolByteArray([255, 255, 255, 63]))
        texture = ImageTexture.new()
        texture.create_from_image(empty_image, 0)

    func _draw():
        draw_texture_rect(texture, Rect2(Vector2(0, 0), size), true)

func _init():
    cursor = Cursor.new()
    scroller = Node2D.new()

func setup():
    cursor.size = cursor_box.size

    add_child(scroller)
    scroller.add_child(cursor)

    custom_rect = Rect2(
        cursor_box.position,
        Vector2(
            cursor_box.size.x,
            item_spacing.y * window_visibleitems + item_spacing.y / 2
        )
    )

    var label_position: Vector2 = Vector2(0, 0)

    for action in actions:
        var label = UiLabel.new()
        label.set_text(action["text"])
        label.set_font(default_font)
        label.position = label_position

        label_map[action["id"]] = label
        label_position.y += item_spacing.y
        scroller.add_child(label)

    update_label_font(selected_action_index, true)

func _process(delta: float):
    update_selected_action_index()
    update_cursor_position()
    update_scroller_position(delta)
    update()

func update_selected_action_index():
    var old_selected_action_index = selected_action_index
    if user_input.any.is_action_just_pressed("D"):
        if selected_action_index + 1 < actions.size():
            selected_action_index += 1
    if user_input.any.is_action_just_pressed("U"):
        if selected_action_index > 0:
            selected_action_index -= 1
    if old_selected_action_index != selected_action_index:
        update_label_font(old_selected_action_index, false)
        update_label_font(selected_action_index, true)
        emit_move_sound()

func update_cursor_position():
    cursor_offset = Vector2(
        0,
        item_spacing.y * selected_action_index
    )

    cursor.position = cursor_box.position + cursor_offset

func update_scroller_position(delta: float):
    var top_edge_diff  = get_cursor_top_edge() - get_scroll_top_edge()
    var bottom_edge_diff = get_cursor_bottom_edge() - get_scroll_bottom_edge()
    if top_edge_diff < 0:
        scroller.position.y = lerp(scroller.position.y, scroller.position.y - top_edge_diff, 0.2)
    if bottom_edge_diff > 0:
        scroller.position.y = lerp(scroller.position.y, scroller.position.y - bottom_edge_diff, 0.2)

func update_label_font(index: int, active: bool):
    var action = actions[index]
    var label = label_map[action["id"]]
    label.set_font(default_font if not active else active_font)

func emit_move_sound():
    var kernel = get_node('/root/main').kernel
    var audio_player = get_node('/root/main').audio_player
    var sound = kernel.get_sound(cursor_move_snd)

    if sound:
        audio_player.play_sound(sound)

func get_scroll_top_edge():
    return cursor_box.position.y - scroller.position.y

func get_scroll_bottom_edge():
    return get_scroll_top_edge() + custom_rect.size.y

func get_cursor_top_edge():
    return cursor_offset.y + cursor_box.position.y

func get_cursor_bottom_edge():
    return get_cursor_top_edge() + cursor_box.size.y

func _draw():
    VisualServer.canvas_item_set_custom_rect(get_canvas_item(), true, custom_rect)
    VisualServer.canvas_item_set_clip(get_canvas_item(), true)
