extends Node2D

# Path to your Python file in the project:
var python_script_path = ProjectSettings.globalize_path("res://gemini/script.py")

# This is the *Godot* path where we want the final file. We'll load from here:
var user_output_path_godot = "user://output2.png"

@onready var sprite := $objectSpawner

func _ready():
	# Center the sprite in the middle of the screen on start
	sprite.position = get_viewport_rect().size / 2

func _input(event):
	if event.is_action_pressed("run_script"):
		run_python_script()

func run_python_script():
	# 1. Find the *actual OS path* for user://output2.png
	#    e.g. C:\Users\You\AppData\Roaming\Godot\app_userdata\YourProject\output2.png
	var python_path = "python"
	var user_output_path_abs = ProjectSettings.globalize_path(user_output_path_godot)

	# 2. Pass that absolute path as an argument to the Python script
	var result = OS.execute(
		python_path,
		PackedStringArray([python_script_path, user_output_path_abs]),
		[],
		true  # block until the script finishes
	)

	# 3. After the script is done, load the image from user://
	load_output_image()

func load_output_image():
	# Instead of ResourceLoader, let’s read the raw PNG bytes from user://
	var raw_image = Image.new()
	var error_code = raw_image.load(user_output_path_godot)
	
	if error_code == OK:
		# Convert the raw image to a Texture2D
		var texture = ImageTexture.create_from_image(raw_image)
		if texture:
			sprite.texture = texture
			sprite.scale = Vector2(0.2, 0.2)  # scale down to 20% size
			sprite.position = get_viewport_rect().size / 2  # center it
			print("✅ Loaded image from user:// and showed on sprite.")
		else:
			print("❌ Could not create texture from Image.")
	else:
		print("❌ load() returned code:", error_code, 
			  " – couldn’t load user://output2.png")
