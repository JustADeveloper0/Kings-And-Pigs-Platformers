extends StaticBody2D

@onready var pass_point: Node2D = $pass_point
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D

var player_on_top = false
var dropping = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dropping:
		dropping = false
	
	var player_y = Global.platform_pass_point_y
	var collision_y = pass_point.global_position.y
	
	if player_on_top and Input.is_action_pressed("drop"):
		collision_shape_2d.disabled = true
		dropping = true

	if player_y != null and not dropping:
		if player_y >= collision_y:
			collision_shape_2d.disabled = true
		else:
			collision_shape_2d.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_on_top = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_on_top = false
