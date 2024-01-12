extends Area2D


@export var speed_x: float = 300.0
@export var speed_y: float = 300.0
@export var starting_health: int = 3
@export var hitbox_epsilon: int = 5
@export var idle_wait: int = 90
@export var release_threshold: float = 0.2

var screen_size: Vector2
var last_heading: String = "n"
var current_heading: String = "n"
var new_heading: String = "n"
var last_key_released: String = ""
var last_release_time: float = 0.0
var idle_frames: int = 0
var full_idle: bool = false
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var adjusted_anim_speed: float = (speed_x+speed_y)/2 / 120 #/ Engine.get_frames_per_second()
	
	# Set velocity
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_e"):
		velocity.x += 1
	if Input.is_action_pressed("move_w"):
		velocity.x -= 1
	if Input.is_action_pressed("move_s"):
		velocity.y += 1
	if Input.is_action_pressed("move_n"):
		velocity.y -= 1

	# Set sprite according to velocity (direction)
	last_heading = current_heading
	if velocity.x > 0 and velocity.y == 0:
		new_heading = "e"
	elif velocity.x < 0 and velocity.y == 0:
		new_heading = "w"
	elif velocity.x == 0 and velocity.y > 0:
		new_heading = "s"
	elif velocity.x == 0 and velocity.y < 0:
		new_heading = "n"
	elif velocity.x > 0 and velocity.y > 0:
		new_heading = "se"
	elif velocity.x > 0 and velocity.y < 0:
		new_heading = "ne"
	elif velocity.x < 0 and velocity.y > 0:
		new_heading = "sw"
	elif velocity.x < 0 and velocity.y < 0:
		new_heading = "nw"

	if new_heading != current_heading:
		last_heading = current_heading
	current_heading = new_heading
	
	if velocity != Vector2.ZERO:
		velocity = velocity.normalized() * speed_x
		if full_idle and $AnimatedSprite2D.frame > 0:
			$AnimatedSprite2D.play("idle_%s" % current_heading, -adjusted_anim_speed*3, true)
		else:
			$AnimatedSprite2D.play("walk_%s" % current_heading, adjusted_anim_speed)
			full_idle = false
		idle_frames = 0
	else:
		idle_frames += 1
		
		if idle_frames <= $AnimatedSprite2D.sprite_frames.get_frame_count("walk_%s" % last_heading) and not full_idle: 
			$AnimatedSprite2D.play("walk_%s" % current_heading, adjusted_anim_speed)
		else:
			# Check if idle_wait has passed
			if idle_frames >= idle_wait and not full_idle:
				$AnimatedSprite2D.play("idle_%s" % last_heading, adjusted_anim_speed)
			elif idle_frames < idle_wait and not full_idle:
				$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count("walk_%s" % last_heading) - 1

			# Stop animation after all idle frames have played
			if $AnimatedSprite2D.frame >= $AnimatedSprite2D.sprite_frames.get_frame_count("idle_%s" % last_heading) - 1:
				$AnimatedSprite2D.stop()
				# Set to last frame of the idle animation
				$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count("idle_%s" % last_heading) - 1
				full_idle = true
			
			
	var hitbox: PackedVector2Array = HitboxFromSprite.generate($AnimatedSprite2D, hitbox_epsilon).get_polygon()
	$CollisionPolygon2D.set_polygon(hitbox)
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	
	
