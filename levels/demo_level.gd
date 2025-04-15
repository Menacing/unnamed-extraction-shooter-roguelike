extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.emit_populate_level.call_deferred()
	LevelManager.add_child(self)
	LevelManager.loaded_level = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
