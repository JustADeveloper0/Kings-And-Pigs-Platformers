extends CharacterBody2D

var was_on_floor = false
var player_body = null

var health = 90
var cooldown = 0
var damage = 0

var is_dead = false
var is_hit = 0

@export var speed = 50
@export var jump_velocity = -250
@export var gravity = 980
@export var player : Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var follow_area: Area2D = $FollowArea
@onready var attack_area: Area2D = $AttackArea
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	
	# Path finding
	var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	
	
	# Handle Cooldowns and Health
	if cooldown > 0:
		if damage != 0:
			is_hit = 0.3
			animated_sprite_2d.play("hit")
		health -= damage
		damage = 0
		cooldown -= delta
		
	if is_hit > 0:
		is_hit -= delta
		
	if is_hit < 0:
		is_hit = 0
	
	if health <= 0:
		is_dead = true
		animated_sprite_2d.play("dead")
		
	if is_dead and animated_sprite_2d.frame == 3:
		queue_free()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle Following
	if player_body != null:	
		if player_body.global_position.x > global_position.x:
			animated_sprite_2d.flip_h = true
			direction.x = 1;
		else:
			animated_sprite_2d.flip_h = false
			direction.x = -1;
	
	# Handle Animations
	if not is_dead and is_hit <= 0:
		if is_on_floor():
			if not was_on_floor:
				animated_sprite_2d.play("ground")
			elif direction:
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("idle")
		else:
			if velocity.y > 0:
				animated_sprite_2d.animation = "fall"
				animated_sprite_2d.play()
			else:
				animated_sprite_2d.animation = "jump"
				animated_sprite_2d.play()

	# Apply Movement
	velocity.x = direction.x * speed if direction.x != 0 else move_toward(velocity.x, 0, speed)
	velocity.y += gravity * delta if not is_on_floor() else 0

	move_and_slide()
	was_on_floor = is_on_floor()
	
func pigDamage(cooldown_given, damage_given):
	if cooldown <= 0:
		cooldown = cooldown_given
		damage = damage_given


func _on_follow_area_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_body = body


func _on_follow_area_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_body = null

func _on_timer_timeout() -> void:
	pass
