extends CharacterBody2D

var was_on_floor = false
var attack = false
var body_entered = null

var attack_cooldown_max = 0.5
var attack_cooldown = 0

@export var speed = 100
@export var jump_velocity = -250
@export var gravity = 980
@export	var damage = 30

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision_shape: CollisionShape2D = $AttackArea/AttackCollisionShape
@onready var platform_pass_point: Node2D = $PlatformPassPoint

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")

	# Update Global Script
	Global.platform_pass_point_y = platform_pass_point.global_position.y

	# Handle Cooldowns
	if attack_cooldown > 0:
		attack_cooldown -= delta	

	# Handle Attack Input
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		attack = true
		attack_cooldown = attack_cooldown_max

	# Update Animations
	if direction > 0:
		animated_sprite_2d.flip_h = false
		attack_collision_shape.position.x = 23
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		attack_collision_shape.position.x = -23
	
	if attack:
		animated_sprite_2d.play("attack")
	else:
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

	# Handle jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite_2d.play("jump")
		
	# Handle Attack
	if attack:
		if animated_sprite_2d.frame == 0:
			if body_entered != null:
				if body_entered.has_method("pigDamage"):
					body_entered.pigDamage(0.3, damage)
		if animated_sprite_2d.frame == 2:
			attack = false

	# Apply movement
	velocity.x = direction * speed if direction else move_toward(velocity.x, 0, speed)
	velocity.y += gravity * delta if not is_on_floor() else 0

	move_and_slide()
	was_on_floor = is_on_floor()


func _on_attack_area_body_entered(body: Node2D) -> void:
	body_entered = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	body_entered = null
	
func is_player():
	return true
