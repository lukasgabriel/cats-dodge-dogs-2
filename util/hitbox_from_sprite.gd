
class_name HitboxFromSprite


static func get_offset(sprite: AnimatedSprite2D) -> Vector2i:
	var bitmap: BitMap = BitMap.new()
	bitmap.create_from_image_alpha(sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_image())
	return(bitmap.get_size()/2)

static func generate_all(sprite: AnimatedSprite2D, hitbox_epsilon: int = 5) -> Dictionary: #<String, Array[CollisionPolygon2D]>:
	var hitboxes: Dictionary #<String, Array[CollisionPolygon2D]>
	var hitbox: CollisionPolygon2D
	var frame_texture: Texture2D
	var hitbox_polygon: PackedVector2Array
	var bitmap: BitMap = BitMap.new()
	var polys: Array[PackedVector2Array]
	
	for animation: String in sprite.sprite_frames.get_animation_names():
		hitboxes[animation] = []
		
		for frame in range(sprite.sprite_frames.get_frame_count(animation)):
			hitbox = CollisionPolygon2D.new()
			
			frame_texture = sprite.sprite_frames.get_frame_texture(animation, frame)
			bitmap.create_from_image_alpha(frame_texture.get_image())
			
			polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, frame_texture.get_size()), hitbox_epsilon)
			
			hitbox_polygon.clear()
			for poly in polys:
				hitbox_polygon = Geometry2D.merge_polygons(hitbox_polygon, poly)[0]
			
			hitbox.set_polygon(hitbox_polygon)
			hitboxes[animation].append(hitbox)
	
	return hitboxes


static func generate(sprite: AnimatedSprite2D, hitbox_epsilon: int = 5): #-> CollisionPolygon2D:
	pass # TODO: Implement/redo
