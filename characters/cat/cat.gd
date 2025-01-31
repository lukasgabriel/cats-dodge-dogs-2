extends Area2D

signal hit
signal win

@export var base_speed_x: float = 300.0
@export var base_speed_y: float = 300.0
@export var speed_x_cap: float = 600.0
@export var speed_y_cap: float = 600.0
@export var sprint_speed_factor: float = 1.5
@export var starting_health: int = 3
@export var hitbox_epsilon: int = 0
@export var idle_wait: int = 90

var screen_size: Vector2
var level_height: int = 2
var last_heading: String = "n"
var current_heading: String = "n"
var new_heading: String = "n"
var last_key_released: String = ""
var last_release_time: float = 0.0
var speed_x: float = 0.0
var speed_y: float = 0.0
var is_sprinting: bool = false
var is_dashing: bool = false
var idle_frames: int = 0
var full_idle: bool = false
var velocity: Vector2 = Vector2.ZERO
var hitboxes: Dictionary #<String, Array[CollisionPolygon2D]>
var offset: Vector2
var win_state: bool = false
var hit_count: int = 0


func _ready() -> void:
	screen_size = get_viewport_rect().size
	level_height = get_parent().level_height
	
	# Pregenerate hitboxes and offset CollisionPolygon once
	hitboxes = HitboxFromSprite.generate_all($AnimatedSprite2D, hitbox_epsilon)
	offset = Vector2(HitboxFromSprite.get_offset($AnimatedSprite2D))
	$CollisionPolygon2D.position -= offset


func _physics_process(delta: float) -> void:
	speed_x = base_speed_x
	speed_y = base_speed_y
	
	is_sprinting = true if Input.is_action_pressed("sprint") else false
	is_dashing = true if Input.is_action_pressed("dash") else false
	
	if is_sprinting:
		speed_x *= sprint_speed_factor
		speed_y *= sprint_speed_factor
	
	# TODO: Better way to regulate animation speed to framerate/player speed/etc.
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
	# TODO: Preserve diagonal resting headings with input buffer or similar

	# TODO: Make sure cat starts out full_idle and facing up
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
	
	$CollisionPolygon2D.set_polygon(hitboxes[$AnimatedSprite2D.animation][$AnimatedSprite2D.frame].get_polygon())
	
	velocity.x = clamp(velocity.x, -speed_x_cap, speed_x_cap)
	velocity.y = clamp(velocity.y, -speed_y_cap, speed_y_cap)
	position += velocity * delta
	position.x = clamp(position.x, 0 + 1.5*offset.x, screen_size.x - 1.5*offset.x)
	position.y = clamp(position.y, -screen_size.y * (level_height - 1), screen_size.y*1.1)
	# TODO: More accurate clamp by including the sprite size, or checking for collison

	if position.y <= (-screen_size.y * (level_height - 1)):
		win_state = true
		Logger.info("Win!")
		win.emit()


func _process(delta: float) -> void:
	pass


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_area_entered(area: Area2D) -> void:
	hit_count += 1
	Logger.info("Hit!")
	hit.emit()
