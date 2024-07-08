extends Camera2D

func focus(n):
	var t = get_tree().create_tween()
	if n == 9:
		t.tween_property(self, "zoom", Vector2(0.55,0.55), 1)
		t.tween_property(self, "position", Vector2(576,435), 1)
	if n == 8:
		t.tween_property(self, "zoom", Vector2(0.8,0.8), 1)
		t.tween_property(self, "position", Vector2(576,665), 1)
	if n == 1:
		t.tween_property(self, "position", Vector2(576,725), 1)
		t.tween_property(self, "zoom", Vector2(1,1), 1)
