extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		_close_self()

func _on_done_button_pressed():
	_close_self()

func _close_self():
	self.queue_free()
