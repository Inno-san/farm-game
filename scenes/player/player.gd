extends CharacterBody2D
var direction :Vector2
var speed := 300
var move_state_machine :AnimationNodeStateMachinePlayback 

func _ready() -> void:
	move_state_machine=$AnimationTree.get("parameters/MoveStateMachine/playback")

func _physics_process(_delta: float) -> void:
	get_input()
	velocity = direction * speed
	move_and_slide()
	animation()


func get_input():
	direction = Input.get_vector("left","right","up","down")

func animation():
	if direction:
		move_state_machine.travel("walk")
		var target_vector: Vector2 = Vector2(round(direction.x),round(direction.y))
		$AnimationTree.set("parameters/MoveStateMachine/walk/blend_position",target_vector)
		$AnimationTree.set("parameters/MoveStateMachine/idle/blend_position",target_vector)
	else:
		move_state_machine.travel("idle")
