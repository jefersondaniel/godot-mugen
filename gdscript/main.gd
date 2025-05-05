extends Node2D

func _init() -> void:
	print("Initializing game")
	var hello = HelloWorld.new()
	hello.connect("some_signal", self.receive_some_signal)
	hello.trigger_signal()

func receive_some_signal():
	print("Some signal was sucessfully received")
