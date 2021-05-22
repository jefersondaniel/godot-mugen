# Options
class Options:
    var difficulty: int = 4
    var life: int = 100
    var time: int = 99
    var team_1vs2life: int = 150
    var team_loseonko: int = 0
    var motif: String = ""
    var gamespeed: int = 0

class Rules:
    var gametype: String = 'VS'
    var default_attack_lifetopowermul: float = 0.7
    var default_gethit_lifetopowermul: float = 0.6
    var super_targetdefencemul: float = 1.5

class Config:
    var gamespeed: int = 60
    var gamewidth: int = 1280
    var gameheight: int = 720
    var language: String = "en"
    var playerprojectilemax: int = 32
    var drawshadows: int = 0
    var afterimagemax: int = 0
    var layeredspritemax: int = 0
    var spritedecompressionbuffersize: int = 0
    var explodmax: int = 256
    var sysexplodmax: int = 128
    var helpermax: int = 56
    var firstrun: int = 1

class Debug:
    var debug: int = 0
    var allowdebugmode: int = 0
    var allowdebugkeys: int = 0
    var speedup: int = 0
    var startstage: String = ""

class Sound:
    var sound: int = 0
    var samplerate: int = 0
    var buffersize: int = 0
    var stereoeffects: int = 0
    var panningwidth: int = 0
    var reversestereo: int = 0
    var wavchannels: int = 0
    var mastervolume: int = 0
    var wavvolume: int = 0
    var bgmvolume: int = 0
    var sfxresamplemethod: String = ""
    var sfxresamplequality: int = 0
    var bgmresamplequality: int = 0

var options: Options = Options.new()
var rules: Rules = Rules.new()
var config: Config = Config.new()
var debug: Debug = Debug.new()
var sound: Sound = Sound.new()
var motif_configuration = null
var fight_configuration = null

func get_value(key: String):
    if key == 'default.gethit.lifetopowermul':
        return rules.default_gethit_lifetopowermul
    if key == 'default.attack.lifetopowermul':
        return rules.default_attack_lifetopowermul
    if key == 'super.targetdefencemul':
        return rules.super_targetdefencemul
    if key == 'gametype':
        return rules.gametype
