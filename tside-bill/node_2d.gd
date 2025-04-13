extends Node2D

# Path to the Python script inside your project:
var python_script_path = ProjectSettings.globalize_path("res://gemini/script.py")

var thread := Thread.new()

# This is the *Godot* path where we want the final file. We'll load from here:
var user_output_path_godot = "user://output2.png"
# Output image path (in user://). The Python script will also place data.json in the same folder.
var user_output_path_godot = "user://output.png"
var data_json_path_godot = "user://data.json"

# We'll store the JSON data here for later usage (another API call, etc.)
var detected_name: String = ""
var detected_color: String = ""

@onready var sprite_node = $objectSpawner  # Example sprite node in your scene

func _ready():
	# Example: place the sprite in the center of the screen on startup
	sprite_node.position = get_viewport_rect().size / 2

func _input(event):
	if event.is_action_pressed("run_script") and fon.get_meta("FlipUp",false):
		fon.play("camera")
		if thread.is_alive():
			print("Thread buisy..")
			return
		thread=Thread.new()
		thread.start(self.run_python_script)

func run_python_script():
	# 1) Convert "user://output.png" to an absolute OS path
	var user_output_path_abs = ProjectSettings.globalize_path(user_output_path_godot)

	# 2) Execute the Python script, passing the absolute output path
	var python_path = "python"  # or "python3", depending on your system
	var args = PackedStringArray([python_script_path, user_output_path_abs])
	var exit_code = OS.execute(python_path, args, [], true)  # block until finished

	if exit_code == 0:
		print("✅ Python script finished successfully.")
	else:
		print("❌ Python script returned exit code:", exit_code)

	# 3. After the script is done, load the image from user://
	call_deferred("load_output_image")

	# 4) Load and parse data.json to store the "name" and "color" for later
	load_data_json()

func load_output_image():
	fon.play("main")
	var raw_image = Image.new()
	var error_code = raw_image.load(user_output_path_godot)
	if error_code != OK:
		print("❌ Could not load final image. Error code:", error_code)
		return

	# Example: resize to 16x16 for a pixel-art style
	raw_image.resize(16, 16, Image.INTERPOLATE_NEAREST)
	var texture = ImageTexture.create_from_image(raw_image)

	if texture:
		sprite_node.texture = texture
		# Example: reset scale or adjust as needed
		sprite_node.scale = Vector2(1, 1)
		print("✅ Loaded output image from user:// and applied to sprite.")
	else:
		print("❌ Failed to create texture from the loaded image.")

func load_data_json():
	# Check if data.json exists
	if not FileAccess.file_exists(data_json_path_godot):
		print("❌ data.json not found at:", data_json_path_godot)
		return

	var file = FileAccess.open(data_json_path_godot, FileAccess.READ)
	if file == null:
		print("❌ Could not open data.json for reading.")
		return

	var content = file.get_as_text()
	file.close()

	# -- Use instance-based parser approach --
	var parser = JSON.new()
	var error = parser.parse(content)

	if error == OK:
		var data_dictionary = parser.get_data()

		# Store name and color in script variables for later use
		if data_dictionary.has("name"):
			detected_name = data_dictionary["name"]
			print("Detected name:", detected_name)

		if data_dictionary.has("color"):
			detected_color = data_dictionary["color"]
			print("Detected color:", detected_color)

	else:
		print("❌ JSON parse error:", parser.get_error_message())
