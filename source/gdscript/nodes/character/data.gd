class Data extends "res://source/gdscript/helpers/parser_helper.gd":
    var life: float = 1000.0 # amount of life to start with
    var power: float = 0.0
    var attack: float = 100.0 # attack power (more is stronger)
    var defence: float = 100.0 # defensive power (more is stronger)
    var fall_defence_up: float = 50.0 # percentage to increase defense everytime player is knocked down
    var liedown_time: float = 60.0 # time which player lies down for, before getting up
    var airjuggle: float = 15.0 # number of points for juggling
    var sparkno: float = 2.0 # default hit spark number for HitDefs
    var guard_sparkno: float = 40.0 # default guard spark number
    var ko_echo: float = 0.0 # 1 to enable echo on KO
    var volume: float = 0.0 # volume offset (negative for softer)
    var int_persist_index: float = 60.0
    var float_persist_index: float = 40.0

    func parse(data: Dictionary):
        if data.has("life"):
            life = float(data["life"])
        if data.has("power"):
            power = float(data["power"])
        if data.has("attack"):
            attack = float(data["attack"])
        if data.has("defence"):
            defence = float(data["defence"])
        if data.has("fall.defence_up"):
            fall_defence_up = float(data["fall.defence_up"])
        if data.has("liedown.time"):
            liedown_time = float(data["liedown.time"])
        if data.has("airjuggle"):
            airjuggle = float(data["airjuggle"])
        if data.has("sparkno"):
            sparkno = float(data["sparkno"])
        if data.has("guard.sparkno"):
            guard_sparkno = float(data["guard.sparkno"])
        if data.has("ko.echo"):
            ko_echo = float(data["ko.echo"])
        if data.has("volume"):
            volume = float(data["volume"])
        if data.has("intpersistindex"):
            int_persist_index = float(data["intpersistindex"])
        if data.has("floatpersistindex"):
            float_persist_index = float(data["floatpersistindex"])

    func get_value(key: String):
        if key == "life":
            return life
        if key == "power":
            return power
        if key == "attack":
            return attack
        if key == "defence":
            return defence
        if key == "fall.defence_up":
            return fall_defence_up
        if key == "liedown.time":
            return liedown_time
        if key == "airjuggle":
            return airjuggle
        if key == "sparkno":
            return sparkno
        if key == "guard.sparkno":
            return guard_sparkno
        if key == "ko.echo":
            return ko_echo
        if key == "volume":
            return volume
        if key == "intpersistindex":
            return int_persist_index
        if key == "floatpersistindex":
            return float_persist_index
        push_error("invalid key: %s" % [key])

class Size extends "res://source/gdscript/helpers/parser_helper.gd":
    var xscale: int = 1 # Horizontal scaling factor.
    var yscale: int = 1 # Vertical scaling factor.
    var ground_back: int = 15 # Player width (back, ground)
    var ground_front: int = 16 # Player width (front, ground)
    var air_back: int = 12 # Player width (back, air)
    var air_front: int = 12 # Player width (front, air)
    var height: int = 60 # Height of player (for opponent to jump over)
    var attack_dist: int = 160 # Default attack distance
    var proj_attack_dist: int = 90 # Default attack distance for projectiles
    var proj_doscale: int = 0 # Set to 1 to scale projectiles too
    var head_pos: Vector2 = Vector2(-5, -90) # Approximate position of head
    var mid_pos: Vector2 = Vector2(-5, -60) # Approximate position of midsection
    var shadowoffset: int = 0 # Number of pixels to vertically offset the shadow
    var draw_offset: Vector2 = Vector2(0, 0) # Player drawing offset in pixels (x, y). Recommended 0,0

    func parse(data: Dictionary):
        if data.has("xscale"):
            xscale = data["xscale"]
        if data.has("yscale"):
            yscale = data["yscale"]
        if data.has("ground.back"):
            ground_back = data["ground.back"]
        if data.has("ground.front"):
            ground_front = data["ground.front"]
        if data.has("air.back"):
            air_back = data["air.back"]
        if data.has("air.front"):
            air_front = data["air.front"]
        if data.has("height"):
            height = data["height"]
        if data.has("attack.dist"):
            attack_dist = data["attack.dist"]
        if data.has("proj.attack.dist"):
            proj_attack_dist = data["proj.attack.dist"]
        if data.has("proj.doscale"):
            proj_doscale = data["proj.doscale"]
        if data.has("head.pos"):
            head_pos = parse_vector(data["head.pos"])
        if data.has("mid.pos"):
            mid_pos = parse_vector(data["mid.pos"])
        if data.has("shadowoffset"):
            shadowoffset = data["shadowoffset"]
        if data.has("draw.offset"):
            draw_offset = parse_vector(data["draw.offset"])

    func get_value(key: String):
        if key == "xscale":
            return xscale
        if key == "yscale":
            return yscale
        if key == "ground.back":
            return ground_back
        if key == "ground.front":
            return ground_front
        if key == "air.back":
            return air_back
        if key == "air.front":
            return air_front
        if key == "height":
            return height
        if key == "attack.dist":
            return attack_dist
        if key == "proj.attack.dist":
            return proj_attack_dist
        if key == "proj.doscale":
            return proj_doscale
        if key == "head.pos":
            return head_pos
        if key == "mid.pos":
            return mid_pos
        if key == "shadowoffset":
            return shadowoffset
        if key == "draw.offset":
            return draw_offset
        push_error("invalid key: %s" % [key])

class Velocity extends "res://source/gdscript/helpers/parser_helper.gd":
    var walk_fwd: Vector2 = Vector2(2.4, 0) # Walk forward
    var walk_back: Vector2 = Vector2(-2.2, 0) # Walk backward
    var run_fwd: Vector2 = Vector2(4.6, 0) # Run forward (x, y)
    var run_back: Vector2 = Vector2(-4.5,-3.8) # Hop backward (x, y)
    var jump_neu: Vector2 = Vector2(0,-8.4) # Neutral jumping velocity (x, y)
    var jump_back: Vector2 = Vector2(-2.55, 0) # Jump back Speed (x, y)
    var jump_fwd: Vector2 = Vector2(2.5, 0) # Jump forward Speed (x, y)
    var runjump_back: Vector2 = Vector2(-2.55,-8.1) # Running jump speeds (opt)
    var runjump_fwd: Vector2 = Vector2(4,-8.1) # .
    var airjump_neu: Vector2 = Vector2(0,-8.1) # .
    var airjump_back: Vector2 = Vector2(-2.55, 0) # Air jump speeds (opt)
    var airjump_fwd: Vector2 = Vector2(2.5, 0) # .
    var air_gethit_groundrecover: Vector2 = Vector2(-.15,-3.5) # Velocity for ground recovery state (x, y) **MUGEN 1.0**
    var air_gethit_airrecover_mul: Vector2 = Vector2(.5,.2) # Multiplier for air recovery velocity (x, y) **MUGEN 1.0**
    var air_gethit_airrecover_add: Vector2 = Vector2(0,-4.5) # Velocity offset for air recovery (x, y) **MUGEN 1.0**
    var air_gethit_airrecover_back: float = -1 # Extra x-velocity for holding back during air recovery **MUGEN 1.0**
    var air_gethit_airrecover_fwd: float = 0 # Extra x-velocity for holding forward during air recovery **MUGEN 1.0**
    var air_gethit_airrecover_up: float = -2 # Extra y-velocity for holding up during air recovery **MUGEN 1.0**
    var air_gethit_airrecover_down: float = 1.5 # Extra y-velocity for holding down during air recovery **MUGEN 1.0**

    func parse(data: Dictionary):
        if data.has("walk.fwd"):
            walk_fwd = parse_vector(data["walk.fwd"])
        if data.has("walk.back"):
            walk_back = parse_vector(data["walk.back"])
        if data.has("run.fwd"):
            run_fwd = parse_vector(data["run.fwd"])
        if data.has("run.back"):
            run_back = parse_vector(data["run.back"])
        if data.has("jump.neu"):
            jump_neu = parse_vector(data["jump.neu"])
        if data.has("jump.back"):
            jump_back = parse_vector(data["jump.back"])
        if data.has("jump.fwd"):
            jump_fwd = parse_vector(data["jump.fwd"])
        if data.has("runjump.back"):
            runjump_back = parse_vector(data["runjump.back"])
        if data.has("runjump.fwd"):
            runjump_fwd = parse_vector(data["runjump.fwd"])
        if data.has("airjump.neu"):
            airjump_neu = parse_vector(data["airjump.neu"])
        if data.has("airjump.back"):
            airjump_back = parse_vector(data["airjump.back"])
        if data.has("airjump.fwd"):
            airjump_fwd = parse_vector(data["airjump.fwd"])
        if data.has("air.gethit.groundrecover"):
            air_gethit_groundrecover = parse_vector(data["air.gethit.groundrecover"])
        if data.has("air.gethit.airrecover.mul"):
            air_gethit_airrecover_mul = parse_vector(data["air.gethit.airrecover.mul"])
        if data.has("air.gethit.airrecover.add"):
            air_gethit_airrecover_add = parse_vector(data["air.gethit.airrecover.add"])
        if data.has("air.gethit.airrecover.back"):
            air_gethit_airrecover_back = float(data["air.gethit.airrecover.back"])
        if data.has("air.gethit.airrecover.fwd"):
            air_gethit_airrecover_fwd = float(data["air.gethit.airrecover.fwd"])
        if data.has("air.gethit.airrecover.up"):
            air_gethit_airrecover_up = float(data["air.gethit.airrecover.up"])
        if data.has("air.gethit.airrecover.down"):
            air_gethit_airrecover_down = float(data["air.gethit.airrecover.down"])

    func get_value(key: String):
        if key == "walk.fwd":
            return walk_fwd
        elif key == "walk.back":
            return walk_back
        elif key == "run.fwd":
            return run_fwd
        elif key == "run.back":
            return run_back
        elif key == "jump":
            return jump_neu
        elif key == "jump.neu":
            return jump_neu
        elif key == "jump.back":
            return jump_back
        elif key == "jump.fwd":
            return jump_fwd
        elif key == "runjump.back":
            return runjump_back
        elif key == "runjump.fwd":
            return runjump_fwd
        elif key == "airjump.neu":
            return airjump_neu
        elif key == "airjump.back":
            return airjump_back
        elif key == "airjump.fwd":
            return airjump_fwd
        elif key == "air.gethit.groundrecover":
            return air_gethit_groundrecover
        elif key == "air.gethit.airrecover.mul":
            return air_gethit_airrecover_mul
        elif key == "air.gethit.airrecover.add":
            return air_gethit_airrecover_add
        elif key == "air.gethit.airrecover.back":
            return air_gethit_airrecover_back
        elif key == "air.gethit.airrecover.fwd":
            return air_gethit_airrecover_fwd
        elif key == "air.gethit.airrecover.up":
            return air_gethit_airrecover_up
        elif key == "air.gethit.airrecover.down":
            return air_gethit_airrecover_down
        push_error("invalid key: %s" % [key])

class Movement extends "res://source/gdscript/helpers/parser_helper.gd":
    var airjump_num: int = 1 # Number of air jumps allowed (opt)
    var airjump_height: int = 35 # Minimum distance from ground before you can air jump (opt)
    var yaccel: float = 0.44 # Vertical acceleration
    var stand_friction: float = 0.85 # Friction coefficient when standing
    var crouch_friction: float = 0.82 # Friction coefficient when crouching
    var stand_friction_threshold: float = 2 # If player's speed drops below this threshold while standing, stop his movement **MUGEN 1.0**
    var crouch_friction_threshold: float = 0.05 # If player's speed drops below this threshold while crouching, stop his movement **MUGEN 1.0**
    var air_gethit_groundlevel: float = 25 # Y-position at which a falling player is considered to hit the ground **MUGEN 1.0**
    var air_gethit_groundrecover_ground_threshold: float = -20 # Y-position below which falling player can use the recovery command **MUGEN 1.0**
    var air_gethit_groundrecover_groundlevel: float = 10 # Y-position at which player in the ground recovery state touches the ground **MUGEN 1.0**
    var air_gethit_airrecover_threshold: float = -1 # Y-velocity above which player may use the air recovery command **MUGEN 1.0**
    var air_gethit_airrecover_yaccel: float = 0.35 # Vertical acceleration for player in the air recovery state **MUGEN 1.0**
    var air_gethit_trip_groundlevel: float = 15 # Y-position at which player in the tripped state touches the ground **MUGEN 1.0**
    var down_bounce_offset: Vector2 = Vector2(0, 20) # Offset for player bouncing off the ground (x, y) **MUGEN 1.0**
    var down_bounce_yaccel: float = 0.4 # Vertical acceleration for player bouncing off the ground **MUGEN 1.0**
    var down_bounce_groundlevel: float = 12 # Y-position at which player bouncing off the ground touches the ground again **MUGEN 1.0**
    var down_friction_threshold: float = 0.05 # If the player's speed drops below this threshold while lying down, stop his movement **MUGEN 1.0**

    func parse(data: Dictionary):
        if data.has("airjump.num"):
            airjump_num = int(data["airjump.num"])
        if data.has("airjump.height"):
            airjump_height = int(data["airjump.height"])
        if data.has("yaccel"):
            yaccel = float(data["yaccel"])
        if data.has("stand.friction"):
            stand_friction = float(data["stand.friction"])
        if data.has("crouch.friction"):
            crouch_friction = float(data["crouch.friction"])
        if data.has("stand.friction.threshold"):
            stand_friction_threshold = float(data["stand.friction.threshold"])
        if data.has("crouch.friction.threshold"):
            crouch_friction_threshold = float(data["crouch.friction.threshold"])
        if data.has("air.gethit.groundlevel"):
            air_gethit_groundlevel = float(data["air.gethit.groundlevel"])
        if data.has("air.gethit.groundrecover.ground.threshold"):
            air_gethit_groundrecover_ground_threshold = float(data["air.gethit.groundrecover.ground.threshold"])
        if data.has("air.gethit.groundrecover.groundlevel"):
            air_gethit_groundrecover_groundlevel = float(data["air.gethit.groundrecover.groundlevel"])
        if data.has("air.gethit.airrecover.threshold"):
            air_gethit_airrecover_threshold = float(data["air.gethit.airrecover.threshold"])
        if data.has("air.gethit.airrecover.yaccel"):
            air_gethit_airrecover_yaccel = float(data["air.gethit.airrecover.yaccel"])
        if data.has("air.gethit.trip.groundlevel"):
            air_gethit_trip_groundlevel = float(data["air.gethit.trip.groundlevel"])
        if data.has("down.bounce.offset"):
            down_bounce_offset = parse_vector(data["down.bounce.offset"])
        if data.has("down.bounce.yaccel"):
            down_bounce_yaccel = float(data["down.bounce.yaccel"])
        if data.has("down.bounce.groundlevel"):
            down_bounce_groundlevel = float(data["down.bounce.groundlevel"])
        if data.has("down.friction.threshold"):
            down_friction_threshold = float(data["down.friction.threshold"])

    func get_value(key: String):
        if key == "airjump.num":
            return airjump_num
        if key == "airjump.height":
            return airjump_height
        if key == "yaccel":
            return yaccel
        if key == "stand.friction":
            return stand_friction
        if key == "crouch.friction":
            return crouch_friction
        if key == "stand.friction.threshold":
            return stand_friction_threshold
        if key == "crouch.friction.threshold":
            return crouch_friction_threshold
        if key == "air.gethit.groundlevel":
            return air_gethit_groundlevel
        if key == "air.gethit.groundrecover.ground.threshold":
            return air_gethit_groundrecover_ground_threshold
        if key == "air.gethit.groundrecover.groundlevel":
            return air_gethit_groundrecover_groundlevel
        if key == "air.gethit.airrecover.threshold":
            return air_gethit_airrecover_threshold
        if key == "air.gethit.airrecover.yaccel":
            return air_gethit_airrecover_yaccel
        if key == "air.gethit.trip.groundlevel":
            return air_gethit_trip_groundlevel
        if key == "down.bounce.offset":
            return down_bounce_offset
        if key == "down.bounce.yaccel":
            return down_bounce_yaccel
        if key == "down.bounce.groundlevel":
            return down_bounce_groundlevel
        if key == "down.friction.threshold":
            return down_friction_threshold

var data = null
var size = null
var velocity = null
var movement = null
var quotes: Dictionary = {}

func parse(user_data: Dictionary):
    data = Data.new()
    data.parse(user_data.get("data", {}))

    size = Size.new()
    size.parse(user_data.get("size", {}))

    velocity = Velocity.new()
    velocity.parse(user_data.get("velocity", {}))

    movement = Movement.new()
    movement.parse(user_data.get("movement", {}))

    quotes = user_data.get("quotes", {})

func get_value(key: String):
    var pieces = Array(key.split("."))
    var prefix = pieces.pop_front()
    var vector_attribute = null
    var remaining_key = null
    var result = null

    if key.ends_with(".x") or key.ends_with(".y"):
        vector_attribute = pieces.pop_back()

    remaining_key = PoolStringArray(pieces).join(".")

    if prefix == "data":
        result = data.get_value(remaining_key)
    elif prefix == "size":
        result = size.get_value(remaining_key)
    elif prefix == "velocity":
        result = velocity.get_value(remaining_key)
    elif prefix == "movement":
        result = movement.get_value(remaining_key)
    else:
        push_error("invalid prefix: %s" % pieces[0])

    if result and vector_attribute:
        result = result.x if vector_attribute == "x" else result.y

    return result
