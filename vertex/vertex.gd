class_name vertex_class extends TextureRect

@export var node_class : PackedScene

var moused:bool=false
var holding:bool=false
var pos:Vector2=Vector2(0,0)
var grab_pos:Vector2
var parent
var nodes:Array[Node_connection]=[]
var left_click:bool=false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_node(coords:Vector2):
	var node=node_class.instantiate()
	node.sprite=self
	node.pos=coords
	nodes.push_back(node)
	
func _draw():
	position=pos*parent.zoom+parent.page_pos
	var draw_hover=true
	var color:Color
	var defcolor:Color=Color.CORNFLOWER_BLUE
	if(parent.current_state==parent.state.line_drawing):
		defcolor=Color.YELLOW
	for node in nodes:
		if(parent.bruh==node):
			continue
		color=defcolor
		if(node.attatched!=null):
			color=Color.BLACK
		var this_pos=node.pos#parent.zoom
		if(((parent.selection==self and parent.current_state==parent.state.normal) or (parent.current_state==parent.state.line_drawing and node!=parent.bruh)) and (this_pos*parent.zoom+position).distance_to(get_viewport().get_mouse_position())<2*parent.zoom):
			draw_hover=false
			color=Color.AQUA
			if(node.attatched!=null):
				color=Color.RED
			if(left_click):
				parent.click_node(node)
			
		draw_circle(this_pos,2,color)
		
	#draw_texture(tex,position)
	
	if(holding):
		draw_rect(Rect2(Vector2(0,0),texture.get_size()),Color.BLACK,false)
	elif(draw_hover and moused):
		draw_rect(Rect2(Vector2(0,0),texture.get_size()),Color.AQUA,false)
		if(left_click):
			if(parent.selection==self):
				holding=true
				grab_pos=parent.mouse_pos-pos
			parent.selection=self
			
	left_click=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	queue_redraw()
	if(!holding):
		return
	if Input.is_mouse_button_pressed(1):
		var newpos:Vector2 = parent.mouse_pos
		pos = newpos-grab_pos
		parent.edit_redraw()
	else:
		holding=false
		parent.register_edit()

func _input(event):
	if(!moused):
		return
	if(event.is_action_pressed("left_click")):
		left_click=true
		parent.clicked_well=true
	if(event.is_action_pressed("right_click")):
		return
		holding=true
		grab_pos=parent.mouse_pos-pos

func _on_mouse_exited():
	moused=false
	pass # Replace with function body.

func _on_mouse_entered():
	moused=true
	pass # Replace with function body.
