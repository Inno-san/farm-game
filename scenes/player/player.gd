extends CharacterBody2D
var direction :Vector2
var last_direction:Vector2
var speed := 200
var move_state_machine :AnimationNodeStateMachinePlayback 
var tool_state_machine :AnimationNodeStateMachinePlayback 
var can_move:=true
@export var tool_direction_offset :int=10
@export var tool_y_offset :int=4
enum Tools{HOE, AXE, WATERC}
enum Seeds {CORN,TOMATO,PUMPKIN}
var current_seed:Global.Seeds =Global.Seeds.CORN
var current_tools:Tools

const tool_connection := {
	Tools.HOE:'hoe',
	Tools.AXE:'axe',
	Tools.WATERC:'water'
}

signal tool_use(tool:Tools,pos:Vector2)
signal seed_use(seed:Seeds,pos:Vector2)
func _ready() -> void:
	move_state_machine=$AnimationTree.get("parameters/MoveStateMachine/playback")
	tool_state_machine = $AnimationTree.get("parameters/ToolStateMachine/playback")



func _physics_process(_delta: float) -> void:
	if can_move:
		get_input()
	if direction:
		last_direction =direction
		if not $stepstimer.time_left:
			$stepstimer.start()
	else:
		$steps.stop()
	velocity = direction * speed * int(can_move)
	move_and_slide()
	animation()


func get_input():
	direction = Input.get_vector("left","right","up","down")
	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(tool_connection[current_tools])
		$AnimationTree.set("parameters/OneShot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		can_move =false
		if current_tools in [Tools.HOE,Tools.WATERC]:
			await $AnimationTree.animation_finished
			tool_use.emit(current_tools,position+last_direction*tool_direction_offset+Vector2(0,tool_y_offset))

	
	if can_move and Input.is_action_just_pressed("tool_forward") or  Input.is_action_just_pressed("tool_backward"):
		var tool_direction := Input.get_axis("tool_backward","tool_forward") as int
		current_tools = posmod(current_tools+tool_direction,Tools.size()) as Tools
	
	if Input.is_action_just_pressed("seed_toggle"):
		current_seed = posmod(current_seed+1,Global.Seeds.size()) as Global.Seeds
	if Input.is_action_just_pressed("plant"):
		can_move=false
		direction=Vector2.ZERO
		seed_use.emit(current_seed,position +last_direction* tool_direction_offset+Vector2(0,tool_y_offset))
		await get_tree().create_timer(0.5).timeout
		can_move=true

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

func axe_use():
	tool_use.emit(current_tools,position+last_direction*tool_direction_offset+Vector2(0,tool_y_offset))


func _on_stepstimer_timeout() -> void:
	$steps.play()
