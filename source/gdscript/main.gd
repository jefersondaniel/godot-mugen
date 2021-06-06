extends Node2D

var Kernel = load('res://source/gdscript/system/kernel.gd')
var AudioPlayer = load('res://source/gdscript/system/audio_player.gd')
var Router = load('res://source/gdscript/system/router.gd')
var kernel = null
var audio_player = null
var router = null

func _init():
    kernel = Kernel.new()
    kernel.load()
    audio_player = AudioPlayer.new()
    add_child(audio_player)
    router = Router.new()
    add_child(router)
