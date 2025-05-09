extends Node2D

func _ready() -> void:
    var title_screen_data = GameManager.title_screen_data
    var background_group = title_screen_data.background_group
    for background in background_group.backgrounds:
        var background_node = BackgroundSprite.from_background(background)
        add_child(background_node)
