extends Label

func _on_slider_value_changed(value):
	self.text = str(int(value))
