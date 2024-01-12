# Adapted from:
# https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-3/sprite-collision-polygons/assets/rigid_body_generator.gd

class_name HitboxFromSprite


static func generate(sprite: AnimatedSprite2D, hitbox_epsilon: int = 5) -> CollisionPolygon2D:
	var hitbox: CollisionPolygon2D = CollisionPolygon2D.new()
	
	var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	
	var bitmap: BitMap = BitMap.new()
	bitmap.create_from_image_alpha(frame_texture.get_image())
	
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, frame_texture.get_size()), hitbox_epsilon)
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		hitbox.add_child(collision_polygon)
		
	return hitbox
