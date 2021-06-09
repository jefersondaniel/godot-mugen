var Animation = load('res://source/gdscript/nodes/sprite/animation.gd')
var AnimationElement = load('res://source/gdscript/nodes/sprite/animation_element.gd')
var AnimationCollision = load('res://source/gdscript/nodes/sprite/animation_collision.gd')

func read(path):
    var file = File.new()
    file.open(path, File.READ)
    var lines = file.get_as_text().split("\n", false)
    file.close()

    var animations = {}

    var current_animation = null
    var current_animation_key = null
    var current_animation_element = 0
    var current_animation_tick = 0
    var current_collision = null

    for line in lines:
        var comment_idx = line.find(';')
        if comment_idx != -1:
            line = line.substr(0, comment_idx)
        line = line.strip_edges().to_lower()

        if not line:
            continue

        if line.begins_with('[begin action '):
            if current_animation:
                if current_collision:
                    current_animation['collisions'].append(current_collision)
                if current_animation['elements'].size() != 0:
                    animations[current_animation_key] = create_animation(current_animation)
                current_animation_element = 0
                current_animation_tick = 0

            var idx_start = 14
            var idx_end = line.find(']')
            current_animation_key = int(line.substr(idx_start, idx_end - idx_start))
            current_collision = null
            current_animation = {
                'identifier': current_animation_key,
                'collisions': [],
                'elements': [],
                'loopstart': 0
            }
            continue
        elif line.begins_with('['):
            # Ignore files with mixed animations and other configurations
            current_animation = null

        if not current_animation:
            continue

        var is_collision_1 = line.begins_with('clsn1[')
        var is_collision_2 = line.begins_with('clsn2[')
        var is_loopstart = line.begins_with('loopstart')

        if is_collision_1 or is_collision_2:
            var idx_start = line.find('=') + 1
            var idx_end = line.length()
            var points = line.substr(idx_start, idx_end - idx_start)
            points = points.split_floats(',')
            if not current_collision or len(points) != 4:
                push_error("Invalid collision instruction: %s" % [line])
                continue
            current_collision['boxes'].append([
                min(points[0], points[2]),
                min(points[1], points[3]),
                max(points[0], points[2]),
                max(points[1], points[3])
            ])
            continue

        if is_loopstart:
            current_animation['loopstart'] = current_animation_element + 1
            continue

        if line.begins_with('clsn'):
            if current_collision != null:
                current_animation['collisions'].append(current_collision)

            current_collision = {
                'type': null,
                'default': null,
                'boxes': [],
                'element': current_animation_element,
            }

            if line.begins_with('clsn1default'):
                current_collision['type'] = 1
                current_collision['default'] = true
            elif line.begins_with('clsn2default'):
                current_collision['type'] = 2
                current_collision['default'] = true
            elif line.begins_with('clsn1'):
                current_collision['type'] = 1
                current_collision['default'] = false
            elif line.begins_with('clsn2'):
                current_collision['type'] = 2
                current_collision['default'] = false
            continue

        line = line.replace(' ', '').replace(',,', '')
        var parameters = line.split(',')
        var parameters_size = parameters.size()
        if parameters_size < 5:
            print("Invalid animation frame: %s" % [line])
            continue
        var flags = []
        if parameters_size > 5:
            for i in range(5, parameters_size):
                flags.append(parameters[i])
        var ticks = int(parameters[4])
        current_animation['elements'].append({
            'groupno': int(parameters[0]),
            'imageno': int(parameters[1]),
            'offset': [int(parameters[2]), int(parameters[3])],
            'ticks': ticks,
            'start_tick': current_animation_tick,
            'flags': flags,
        })
        current_animation_element += 1
        current_animation_tick += max(1, ticks)

    if current_animation:
        if current_collision:
            current_animation['collisions'].append(current_collision)
        if current_animation['elements'].size() != 0:
            animations[current_animation_key] = create_animation(current_animation)

    return animations

func create_animation(animation_data):
    var elements = []
    var collisions = []
    var element_id = 0

    for element_data in animation_data['elements']:
        var element = AnimationElement.new(
            element_id,
            element_data['groupno'],
            element_data['imageno'],
            Vector2(element_data['offset'][0], element_data['offset'][1]),
            element_data['ticks'],
            element_data['start_tick'],
            element_data['flags']
        )
        elements.append(element)
        element_id += 1

    for collision_data in animation_data['collisions']:
        var collision = AnimationCollision.new(
            collision_data['type'],
            collision_data['default'],
            collision_data['boxes'],
            collision_data['element']
        )
        collisions.append(collision)

    var identifier = int(animation_data['identifier'])

    return Animation.new(identifier, animation_data['loopstart'], elements, collisions)
