extends Node2D

func bajar():
	var t = create_tween()
	t.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	t.tween_callback(
		func():
			visible = false
	)
	await t.finished
