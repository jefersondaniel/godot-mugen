extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func load_configuration(path):
	var file = File.new()
	file.open(path, File.READ)
	var lines = file.get_as_text().split("\n", false)
	file.close()
	
	var sections = {}

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
			if current_section:
				sections[current_section_key] = current_section
			var idx_start = 1
			var idx_end = line.find(']')
			current_section_key = line.substr(idx_start, idx_end - idx_start).to_lower()
			current_section = {}
			continue

		if current_section == null:
			continue
		
		var equal_idx = line.find('=')
		var line_size = line.length()
		
		if equal_idx == -1:
			continue

		var key = line.substr(0, equal_idx).to_lower().strip_edges()
		var value = line.substr(equal_idx + 1, line_size - equal_idx).strip_edges()
		current_section[key] = value

	if current_section:
		sections[current_section_key] = current_section

	return sections
