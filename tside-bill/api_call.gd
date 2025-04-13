extends Node2D

@onready var label_node = $Label


var data_json_path_godot = "user://data.json"


var sec_python_script_path = ProjectSettings.globalize_path("res://gemini/script2.py")


func _ready():
	var name = load_name_from_data_json()
	if name == "":
		print("No valid 'name' found in data.json, skipping script.")
		return

func api_answer(person):
	run_script_with_item(name, person)

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

func run_script_with_item(name: String, person: String):
	var python_path = "python"  # or "python3" on some systems
	var output_lines = []

	# 3. Call the script, capturing its stdout in output_lines
	var exit_code = OS.execute(
		python_path,
		[sec_python_script_path, name, person],
		output_lines, 
		true  # block until finished
	)

	if exit_code != 0:
		print("❌ Python script returned exit code:", exit_code)
		return

	# 4. Combine script output into a single string
	var raw_output = ""
	for line in output_lines:
		raw_output += line

	# 5. Parse the script's JSON output, e.g. { "text_answer": "<string>", "decision": bool }
	var parser = JSON.new()
	var error_code = parser.parse(raw_output)
	if error_code == OK:
		var response_data = parser.get_data()

		if response_data.has("text_answer"):
			label_node.text = response_data["text_answer"]
			print("Professor's reply:", response_data["text_answer"])
		else:
			print("❌ No 'text_answer' key in the returned JSON.")
	else:
		print("❌ JSON parse error from second script:", parser.get_error_message())
		print("Raw output:\n", raw_output)
