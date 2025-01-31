extends Node2D


@export var textures: SpriteFrames
@export var shader_material: ShaderMaterial

var level_height: int = 2
var level_type: String = "grassy"


func setup_background():
	var screen_size = get_viewport_rect().size
	var frame_count = textures.get_frame_count(level_type)
	var texture_size = textures.get_frame_texture(level_type, 0).get_size()
	
	# Calculate number of tiles needed to cover screen
	var viewport_tiles_x = int(screen_size.x / texture_size.x / self.scale.x) + 1
	var viewport_tiles_y = int(screen_size.y / texture_size.y / self.scale.y) + 1
	
	# Calculate total number of tiles drawn
	var num_tiles_x = viewport_tiles_x
	var num_tiles_y = (viewport_tiles_y * level_height) - viewport_tiles_y
	
	for y in range(viewport_tiles_y, -num_tiles_y, -1):
		for x in range(num_tiles_x):
			var sprite = Sprite2D.new()
			sprite.texture = textures.get_frame_texture(level_type, randi() % frame_count)
			# Position each tile based on its index and size
			sprite.position = Vector2(x * texture_size.x, y * texture_size.y)
			sprite.use_parent_material = true
			add_child(sprite)


func _ready() -> void:
	material = shader_material
	level_type = get_parent().level_type
	level_height = get_parent().level_height
	setup_background()
