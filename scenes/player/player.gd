extends CharacterBody2D
var direction :Vector2
var speed := 300
var move_state_machine :AnimationNodeStateMachinePlayback 
var tool_state_machine :AnimationNodeStateMachinePlayback 
var can_move:=true

enum Tools{HOE, AXE, WATERC}
var current_tools:Tools = Tools.HOE

const tool_connection := {
	Tools.HOE:'hoe',
	Tools.AXE:'axe',
	Tools.WATERC:'water'
}
func _ready() -> void:
	move_state_machine=$AnimationTree.get("parameters/MoveStateMachine/playback")
	tool_state_machine = $AnimationTree.get("parameters/ToolStateMachine/playback")



func _physics_process(_delta: float) -> void:
	if can_move:
		get_input()
	velocity = direction * speed * int(can_move)
	move_and_slide()
	animation()


func get_input():
	direction = Input.get_vector("left","right","up","down")
	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(tool_connection[current_tools])
		$AnimationTree.set("parameters/OneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		can_move =false
	
	
	if Input.is_action_just_pressed("tool_forward") or  Input.is_action_just_pressed("tool_backward"):
		var tool_direction := Input.get_axis("tool_backward","tool_forward") as int
		current_tools = posmod(current_tools+tool_direction,Tools.size()) as Tools
	

func animation():
	if direction:
		move_state_machine.travel("walk")
		var target_vector: Vector2 = Vector2(round(direction.x),round(direction.y))
		$AnimationTree.set("parameters/MoveStateMachine/walk/blend_position",target_vector)
		$AnimationTree.set("parameters/MoveStateMachine/idle/blend_position",target_vector)
		for state in tool_connection.values():
			$AnimationTree.set("parameters/ToolStateMachine/"+ state +"/blend_position",target_vector)
	else:
		move_state_machine.travel("idle")


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move =true
