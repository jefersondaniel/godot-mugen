extends Node2D

var Kernel = load('res://source/gdscript/system/kernel.gd')
var AudioPlayer = load('res://source/gdscript/system/audio_player.gd')
var Router = load('res://source/gdscript/system/router.gd')
var Store = load('res://source/gdscript/system/store.gd')

func _init():
    var kernel = Kernel.new()
    kernel.load()
    constants.container["kernel"] = kernel

    var store = Store.new()
    constants.container["store"] = store

    var audio_player = AudioPlayer.new()
    constants.container["audio_player"] = audio_player
    add_child(audio_player)

    var router = Router.new()
    constants.container["router"] = router
    add_child(router)
