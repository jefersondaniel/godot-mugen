func read(path, allow_lines=false):
    var file = File.new()
    file.open(path, File.READ)
    var text = file.get_as_text()
    file.close()
    return read_string(text, allow_lines)

func read_string(text: String, allow_lines=false):
    var lines = text.split("\n", false)
    var sections = []

    var current_section = null
    var current_section_key = null

    for line in lines:
        var comment_idx = line.find(';')
        if comment_idx != -1:
            line = line.substr(0, comment_idx)
        line = line.strip_edges()

        if not line:
            continue

        if line.begins_with('['):
            if current_section != null:
                sections.append({
                    'key': current_section_key,
                    'attributes': current_section
                })
            var idx_start = 1
            var idx_end = line.find(']')
            current_section_key = line.substr(idx_start, idx_end - idx_start).to_lower()
            current_section = {}
            if allow_lines:
                current_section['lines'] = []
            continue

        if current_section == null:
            continue

        var equal_idx = line.find('=')
        var line_size = line.length()

        if equal_idx <= 0:
            if allow_lines:
                current_section['lines'].append(line)
            continue

        var key = line.substr(0, equal_idx).to_lower().strip_edges()
        var value = line.substr(equal_idx + 1, line_size - equal_idx).strip_edges()

        if key.substr(0, 7) == 'trigger':
            current_section[key] = current_section.get(key, [])
            current_section[key].append(value)
            continue

        if current_section_key in ['data', 'size', 'velocity', 'movement'] or current_section_key.ends_with('quote'):
            if value.begins_with('"'):
                value = value.lstrip('"').rstrip('"')
            else:
                var numbers = []
                var pieces = value.split(',')

                for piece in pieces:
                    if piece.strip_edges().is_valid_float():
                        numbers.append(float(piece))

                if numbers.size() == pieces.size():
                    value = numbers if numbers.size() > 1 else numbers[0]

        current_section[key] = value

    if current_section != null:
        sections.append({
            'key': current_section_key,
            'attributes': current_section
        })

    return sections
