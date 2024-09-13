extends CSGSphere3D
class_name MapSelectSphere

var tween: Tween
@onready var _initial_rotation:float = self.rotation_degrees.y

func _ready():
	# Create the Tween node
	tween = create_tween()
	
	# Start the rotation loop
	start_rotation_loop()
	

func start_rotation_loop():
	# Ensure the Tween is not currently running
	tween.stop()
	
	# Set the initial and target rotations (in radians)
	var initial_rotation = rotation_degrees.y
	var target_rotation = initial_rotation + 360.0
	
	# Add the Tween animation
	tween.tween_property(self, "rotation_degrees:y", target_rotation, 4.0)
	tween.tween_callback(reset_rotation)
	
	# Loop the animation
	tween.finished.connect(_on_tween_finished)
	tween.play()

func reset_rotation():
	# Reset rotation to initial state
	rotation_degrees.y = _initial_rotation

func _on_tween_finished():
	# Start the rotation loop again
	start_rotation_loop()

func use(player:Player):
	player.toggle_map_select.emit()
