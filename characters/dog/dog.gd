extends Area2D


@export var speed_x: float = 300.0
@export var speed_x_cap: float = 600.0
@export var hitbox_epsilon: int = 0
@export var idle_wait: int = 90

@export var dog_types_and_weights = {
	'white': 0.2, 
	'bw': 0.2, 
	'black': 0.15, 
	'brown': 0.3, 
	'exotic': 0.15,
	}

var screen_size: Vector2
var last_heading: String = "n"
var current_heading: String = "n"
var new_heading: String = "n"
var idle_frames: int = 0
var full_idle: bool = false
var velocity: float = 1.0
var hitboxes: Dictionary #<String, Array[CollisionPolygon2D]>
var offset: Vector2


func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	# Pregenerate hitboxes
	hitboxes = HitboxFromSprite.generate_all($AnimatedSprite2D, hitbox_epsilon)
	offset = Vector2(HitboxFromSprite.get_offset($AnimatedSprite2D))
	$CollisionPolygon2D.position -= offset


func _process(delta: float) -> void:
	# TODO: Better way to regulate animation speed to framerate/player speed/etc.
	var adjusted_anim_speed: float = (speed_x)/2 / 120 #/ Engine.get_frames_per_second()
	
	# Set sprite according to velocity (direction)
	last_heading = current_heading
	if velocity > 0:
		new_heading = "e"
		$AnimatedSprite2D.flip_h = false
		$CollisionPolygon2D.scale.x = 1
	elif velocity < 0:
		new_heading = "w"
		$AnimatedSprite2D.flip_h = true
		$CollisionPolygon2D.scale.x = -1

	if new_heading != current_heading:
		last_heading = current_heading
	current_heading = new_heading
	
	if velocity != 0.0:
		if full_idle and $AnimatedSprite2D.frame > 0:
			$AnimatedSprite2D.play("idle", -adjusted_anim_speed*3, true)
		else:
			$AnimatedSprite2D.play("walk", adjusted_anim_speed)
			full_idle = false
		idle_frames = 0
	else:
		idle_frames += 1
		
		if idle_frames <= $AnimatedSprite2D.sprite_frames.get_frame_count("walk") and not full_idle: 
			$AnimatedSprite2D.play("walk", adjusted_anim_speed)
		else:
			# Check if idle_wait has passed
			if idle_frames >= idle_wait and not full_idle:
				$AnimatedSprite2D.play("idle", adjusted_anim_speed)
			elif idle_frames < idle_wait and not full_idle:
				$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count("walk") - 1

			# Stop animation after all idle frames have played
			if $AnimatedSprite2D.frame >= $AnimatedSprite2D.sprite_frames.get_frame_count("idle") - 1:
				$AnimatedSprite2D.stop()
				# Set to last frame of the idle animation
				$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count("idle") - 1
				full_idle = true
				
	$CollisionPolygon2D.set_polygon(hitboxes[$AnimatedSprite2D.animation][$AnimatedSprite2D.frame].get_polygon())
	
	position.x += velocity * delta * speed_x
	
	# TODO: More accurate clamp by including the sprite size, or checking for collison
	if position.x >= screen_size.x - 3*offset.x:
		velocity = -velocity
		$CollisionPolygon2D.position.x += 2*offset.x
	if position.x <= 0 + 3*offset.x:
		velocity = -velocity
		$CollisionPolygon2D.position.x -= 2*offset.x
		
