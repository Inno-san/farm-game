extends Node2D
@onready var player :=$Objects/Player
var plant_scene:PackedScene=preload("res://scenes/plants/plant.tscn")
var terrain_layer := 0
var tilesize := 16
@export var daytime:Gradient

var watered:bool=false
func _process(_delta: float) -> void:
	var daytime_point:float=1.0-$Day_Timer.time_left/ $Day_Timer.wait_time
	$CanvasModulate.color=daytime.sample(daytime_point)
	if Input.is_action_just_pressed("ui_focus_next"):
		day_switch()

func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	$hoe_sound.play()
	var grid_pos:=Vector2i(int(pos.x/tilesize),int(pos.y/tilesize))
	if tool == player.Tools.HOE:
		var cell=$layers/Grasslayer.get_cell_tile_data(grid_pos) as TileData
		if cell and cell.get_custom_data('usable'):
			$layers/soillayer.set_cells_terrain_connect([grid_pos],0,0)
	if tool == player.Tools.WATERC:
		$water_sound.play()
		var soil_cell= $layers/soillayer.get_cell_tile_data(grid_pos) as TileData
		if soil_cell:
			$layers/watersoil.set_cell(grid_pos,0,Vector2i(randi_range(0,2),0))
			
	if tool== player.Tools.AXE:
		$axe_sound.play()
		for tree in get_tree().get_nodes_in_group("Trees"):
			if tree.position.distance_to(pos)<10:
				tree.hit()


func _on_player_seed_use(seedenum: int, pos: Vector2) -> void:
	var grid_pos:=Vector2i(int(pos.x/tilesize),int(pos.y/tilesize))
	var cell = $layers/soillayer.get_cell_tile_data(grid_pos) as TileData
	if cell:
		var plant_pos:Vector2= Vector2(grid_pos.x*tilesize+8,grid_pos.y*tilesize-4)
		var plant = plant_scene.instantiate()as StaticBody2D
		plant.setup(seedenum,grid_pos)
		$Objects.add_child(plant)
		plant.position =plant_pos
		watered =true
	
	
func day_switch():
	var tween = create_tween()
	tween.tween_property($CanvasLayer/ColorRect,'modulate:a',1.0,1)
	tween.tween_callback(level_reset)
	tween.tween_interval(1.0)
	tween.tween_property($CanvasLayer/ColorRect,'modulate:a',0.0,1)

func level_reset():
	
	for plant in get_tree().get_nodes_in_group('Plalnts'):
		plant.grow(plant.grid_positon in $layers/watersoil.get_used_cells())
	$layers/watersoil.clear()
	$Day_Timer.start()
