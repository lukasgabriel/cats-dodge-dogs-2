extends Camera2D

var screen_size: Vector2
var level_height: int = 2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	level_height = get_parent().get_parent().level_height
	
	limit_bottom = screen_size.x * 1.5
	limit_top = -screen_size.y * (level_height - 1)

func _process(delta: float) -> void:
	pass
