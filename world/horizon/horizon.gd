extends Node2D


@export var texture: Texture2D

var level_height: int = 2


func setup_horizon():
	var screen_size = get_viewport_rect().size
	var horizon = Sprite2D.new()
	var texture_size = texture.get_size()
	
	horizon.texture = texture
	
	horizon.apply_scale(screen_size / texture_size)
	
	horizon.position.x = screen_size.x / 2
	horizon.position.y = screen_size.y / 2 + -screen_size.y * (level_height - 1)
	
	add_child(horizon)


func _ready() -> void:
	level_height = get_parent().level_height
	setup_horizon()
