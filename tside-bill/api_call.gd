extends Node2D




var data_json_path_godot = "user://data.json"


var sec_python_script_path = ProjectSettings.globalize_path("res://gemini/script2.py")




func _ready():
	var name = load_name_from_data_json()
	if name == "":
		print("No valid 'name' found in data.json, skipping script.")
		return
		
	print(api_answer("grumpy"));


func api_answer(person):
	print("name")
	return run_script_with_item(load_name_from_data_json(), person)

func load_name_from_data_json() -> String:
	if not FileAccess.file_exists(data_json_path_godot):
		print("❌ data.json not found at:", data_json_path_godot)
		return ""

	var file = FileAccess.open(data_json_path_godot, FileAccess.READ)
	if file == null:
		print("❌ Could not open data.json for reading.")
		return ""

	var content = file.get_as_text()
	file.close()

	var parser = JSON.new()
	var error_code = parser.parse(content)
	if error_code == OK:
		var dic = parser.get_data()
		if dic.has("name"):
			var name = dic["name"]
			print("Detected name:", name)
			return name
		else:
			print("❌ 'name' key not found in data.json.")
			return ""
	else:
		print("❌ JSON parse error:", parser.get_error_message())
		return ""

func run_script_with_item(name: String, person: String) -> Dictionary:
	var python_path = "python"  # or "python3" on some systems
	var output_lines = []

	var exit_code = OS.execute(
		python_path,
		[sec_python_script_path, name, person],
		output_lines, 
		true
	)

	if exit_code != 0:
		print("❌ Python script returned exit code:", exit_code)
		# Return an empty dictionary or some fallback
		return {}

	var raw_output = ""
	for line in output_lines:
		raw_output += line

	var parser = JSON.new()
	var error_code = parser.parse(raw_output)
	if error_code == OK:
		var response_data = parser.get_data()

		# If we expect { "text_answer": "<string>", "decision": <bool> }
		if response_data.has("text_answer") and response_data.has("decision"):
			var text_answer = response_data["text_answer"]
			var decision = response_data["decision"]
			print("Professor's reply:", text_answer, "Decision:", decision)
			# Return a dictionary with both
			return {
				"text_answer": text_answer,
				"decision": decision
			}
		else:
			print("❌ No 'text_answer' or 'decision' key in returned JSON.")
			return {}
	else:
		print("❌ JSON parse error from second script:", parser.get_error_message())
		print("Raw output:\n", raw_output)
		return {}
