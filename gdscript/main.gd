extends Node2D

var TitleScreen = preload("res://gdscript/screens/title_screen.gd")

var current_screen: Node2D

func _init() -> void:
	GameManager.configuration_directory = "res://mugen-data"
	GameManager.connect("state_changed", self.on_state_changed)

func _physics_process(_delta: float) -> void:
	GameManager.update()

func on_state_changed(state) -> void:
	if state == "FatalError":
		print("Error: ", GameManager.error_message)
		return

	if state == "ConfigurationLoaded":
		configure_screen_size()

	if state == "TitleScreen":
		show_screen(TitleScreen.new())

func configure_screen_size() -> void:
	var localcoord = GameManager.core_assets.get_localcoord()
	get_viewport().size = localcoord
	$'/root'.set_content_scale_size(localcoord)
	get_node('Camera2D').offset = Vector2(-(localcoord.x / 2.0), 0)

func show_screen(screen: Node2D) -> void:
	if current_screen:
		remove_child(current_screen)
	current_screen = screen
	add_child(screen)
