func read(path, allow_lines=false, replace_key_dots=false):
    var file = File.new()
    file.open(path, File.READ)
    var text = file.get_as_text()
    file.close()
    return read_string(text, allow_lines, replace_key_dots)

func read_string(text: String, allow_lines=false, replace_key_dots=false):
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
        var comma_idx = line.find(',')
        var line_size = line.length()

        # checking commas allow this line pattern, kfm.def, option=value
        if equal_idx <= 0 or (comma_idx > 0 and equal_idx > comma_idx):
            if allow_lines:
                current_section['lines'].append(line)
            continue

        var key = line.substr(0, equal_idx).to_lower().strip_edges()
        var value = line.substr(equal_idx + 1, line_size - equal_idx).strip_edges()

        if replace_key_dots:
            key = key.replace(".", "_")

        if key.substr(0, 7) == 'trigger':
            current_section[key] = current_section.get(key, [])
            current_section[key].append(value)
            continue

        # Commented because broke string expressions
        # if value.begins_with('"'):
        #    value = value.lstrip('"').rstrip('"')

        current_section[key] = value

    if current_section != null:
        sections.append({
            'key': current_section_key,
            'attributes': current_section
        })

    return sections
