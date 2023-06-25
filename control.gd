class_name control extends Node2D

var page_x:int=500
var page_y:int=200
var page_width:int=1100
var page_height:int=700
var zoom:float=1
var zoom_min:float=0.1
var zoom_max:float=5
var holding:bool=false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(3):
		if(!holding):
			holding=true
			print("bruh")
	else:
		holding=false
	queue_redraw()
	pass



func _draw():
	draw_rect(Rect2(page_x,page_y,page_width*zoom,page_height*zoom),Color.DARK_SEA_GREEN)
