extends Object

func read(path):
    var file = File.new()
    file.open(path, File.READ)
    var lines = file.get_as_text().split("\n", false)
    file.close()

    var animations = {}

    var current_animation = null
    var current_animation_key = null
    var current_animation_set = null
    var current_animation_frame = 0
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
                if current_animation['sets'][0]['frames'].size() != 0:
                    animations[current_animation_key] = current_animation
                current_animation_set = null
                current_animation_frame = 0

            var idx_start = 14
            var idx_end = line.find(']')
            current_animation_key = int(line.substr(idx_start, idx_end - idx_start))
            current_animation_set = {'frames': []}
            current_collision = null
            current_animation = {
                'collisions': [],
                'sets': [current_animation_set],
            }
            continue

        if not current_animation:
            continue

        var is_collision_1 = line.begins_with('clsn1[')
        var is_collision_2 = line.begins_with('clsn2[')
        var is_loopstart = line.begins_with('loopstart')

        if is_collision_1 or is_collision_2:
            var idx_start = line.find('=') + 1
            var idx_end = line.length() - 1
            var points = line.substr(idx_start, idx_end - idx_start)
            var clsn_type = 1 if is_collision_1 else 2
            points = points.split_floats(',')
            if not current_collision:
                push_error("Invalid collision instruction: %s" % [line])
                continue
            current_collision['boxes'].append(points)
            continue

        if is_loopstart:
            current_animation_set = {'frames': []}
            current_animation['sets'].append(current_animation_set)
            continue

        if line.begins_with('clsn'):
            if current_collision != null:
                current_animation['collisions'].append(current_collision)

            current_collision = {
                'type': null,
                'default': null,
                'boxes': [],
                'frame': current_animation_frame,
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
        current_animation_set['frames'].append({
            'groupno': int(parameters[0]),
            'imageno': int(parameters[1]),
            'offset': [int(parameters[2]), int(parameters[3])],
            'ticks': int(parameters[4]),
            'flags': flags,
        })
        current_animation_frame += 1

    if current_animation:
        if current_collision:
            current_animation['collisions'].append(current_collision)
        if current_animation['sets'][0]['frames'].size() != 0:
            animations[current_animation_key] = current_animation

    return animations
