extends Object

var id: int = 0
var groupno: int = 0
var imageno: int = 0
var offset: Vector2 = Vector2(0, 0)
var ticks: int = 1
var start_tick: int = 0
var flags: Array = []

func _init(_id, _groupno, _imageno, _offset, _ticks, _start_tick, _flags):
    id = _id
    groupno = _groupno
    imageno = _imageno
    offset = _offset
    ticks = _ticks
    start_tick = _start_tick
    flags = _flags
