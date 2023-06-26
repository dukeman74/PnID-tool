extends Node2D

var cnt = 0
var mousePos = Vector2.ZERO
var polyLineOrigin = Vector2.ZERO
var polyLineEnd = Vector2.ZERO
var newLine = false
var start = true
var bigLineArray = PackedVector2Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	#bigLineArray.append(polyLineOrigin)
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			polyLineOrigin = mousePos
			if start == true:
				bigLineArray.append(polyLineOrigin)
				start = false
			newLine = true
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			polyLineEnd = mousePos
			bigLineArray.append(polyLineEnd)
			newLine = false
			polyLineOrigin = polyLineEnd
			newLine = true
			
		
			

func _draw():
	draw_polyline(bigLineArray,Color.DEEP_SKY_BLUE)
	if newLine == true:
		draw_line(polyLineOrigin,mousePos, Color.BLUE_VIOLET)
	elif  newLine == false:
		draw_line(polyLineOrigin,polyLineEnd, Color.BLUE_VIOLET)
	#draw_polyline()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cnt +=12 * delta
	mousePos = get_viewport().get_mouse_position()
	#print(get_viewport().get_mouse_position())
	print(mousePos)
	queue_redraw()
	pass
