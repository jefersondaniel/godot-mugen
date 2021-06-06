extends Node2D

var UiMenu = load('res://source/gdscript/nodes/ui/menu.gd')
var BackgroundGroup = load('res://source/gdscript/nodes/ui/background_group.gd')

signal on_menu_action(action)

var title_info = null
var menu_item_font = null
var menu_item_active_font = null
var background_definition = null
var kernel = null
var setup = false

func _ready():
    if setup:
        return

    setup = true
    kernel = get_node('/root/main').kernel
    title_info = kernel.get_motif().title_info
    background_definition = kernel.get_motif().backgrounds["title"]

    setup_background()
    setup_menu()

func setup_menu():
    menu_item_font = kernel.get_font(title_info.menu_item_font)
    menu_item_active_font = kernel.get_font(title_info.menu_item_active_font)

    var menu = UiMenu.new()
    menu.position = title_info.menu_pos * kernel.get_scale()
    menu.item_spacing = title_info.menu_item_spacing * kernel.get_scale()
    menu.window_margins_y = title_info.menu_window_margins_y * kernel.get_scale()
    menu.window_visibleitems = title_info.menu_window_visibleitems
    menu.default_font = menu_item_font
    menu.active_font = menu_item_active_font
    menu.cursor_visible = title_info.menu_boxcursor_visible
    menu.cursor_move_snd = title_info.cursor_move_snd
    menu.cursor_done_snd = title_info.cursor_done_snd
    menu.cursor_box = Rect2(
        title_info.menu_boxcursor_coords[0],
        title_info.menu_boxcursor_coords[1],
        title_info.menu_boxcursor_coords[2] - title_info.menu_boxcursor_coords[0],
        title_info.menu_boxcursor_coords[3] - title_info.menu_boxcursor_coords[1]
    )
    menu.actions = [
        {"id": constants.MENU_ARCADE, "text": title_info.menu_itemname_arcade},
        {"id": constants.MENU_VERSUS, "text": title_info.menu_itemname_versus},
        {"id": constants.MENU_TEAMARCADE, "text": title_info.menu_itemname_teamarcade},
        {"id": constants.MENU_TEAMVERSUS, "text": title_info.menu_itemname_teamversus},
        {"id": constants.MENU_TEAMCOOP, "text": title_info.menu_itemname_teamcoop},
        {"id": constants.MENU_SURVIVAL, "text": title_info.menu_itemname_survival},
        {"id": constants.MENU_SURVIVALCOOP, "text": title_info.menu_itemname_survivalcoop},
        {"id": constants.MENU_TRAINING, "text": title_info.menu_itemname_training},
        {"id": constants.MENU_WATCH, "text": title_info.menu_itemname_watch},
        {"id": constants.MENU_OPTIONS, "text": title_info.menu_itemname_options},
        {"id": constants.MENU_EXIT, "text": title_info.menu_itemname_exit},
    ]
    menu.setup()
    menu.connect("on_action", self, "dispatch_menu_action")

    add_child(menu)

func setup_background():
    var background_group = BackgroundGroup.new()
    background_group.images = kernel.get_images()
    background_group.setup(background_definition)

    add_child(background_group)

func dispatch_menu_action(action):
    emit_signal("on_menu_action", action)
