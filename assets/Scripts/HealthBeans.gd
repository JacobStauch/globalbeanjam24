extends HBoxContainer

func update_health(value):
	for i in get_child_count():
		get_child(i).visible = value > i
		set_size(Vector2(size.x - 130, size.y))
