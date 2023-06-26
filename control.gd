class_name control extends Node2D

@export var sprite_class : PackedScene
@export var connection_class : PackedScene
@export var elixer_tex : Texture

var page_pos:Vector2=Vector2(500,200)
var page_dimensions:Vector2 = Vector2(1100,700)
var zoom:float=1
var zoom_min:float=0.1
var zoom_max:float=5
var zoom_mod:float=0.1
var holding:bool=false
var holding_position:Vector2
var sprites:Array[Sprite_class] = []
var nodes_dict:Dictionary = {}
var connections:Dictionary = {}
var mouse_pos:Vector2
var bruh:Node_connection=null
var vector_vector_vector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("scroll_up"):
		zoom_change(zoom_mod)
	if event.is_action_pressed("scroll_down"):
		zoom_change(-zoom_mod)
	if event.is_action_pressed("key_0"):
		var this_sprite=sprite_class.instantiate()
		this_sprite.position=Vector2(200,200)
		this_sprite.scale=Vector2(zoom,zoom)
		add_child(this_sprite)
		sprites.push_back(this_sprite)
	if event.is_action_pressed("key_9"):
		var this_sprite=sprite_class.instantiate()
		this_sprite.position=Vector2(200,200)
		this_sprite.scale=Vector2(zoom,zoom)
		add_child(this_sprite)
		sprites.push_back(this_sprite)
		this_sprite.texture=elixer_tex
		this_sprite.add_node(Vector2(16,30))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	mouse_pos=mouse_in_terms_of_page()
	if Input.is_mouse_button_pressed(3):
		if(!holding):
			holding=true
			holding_position = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			var newpos:Vector2 = get_viewport().get_mouse_position()
			page_pos += newpos-holding_position
			get_viewport().warp_mouse(holding_position)
	else:
		holding=false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_redraw()
	pass

func zoom_change(amount):
	var oldzoom:float = zoom
	var old_pos=mouse_in_terms_of_page()
	zoom=clamp(zoom+amount,zoom_min,zoom_max)
	if(zoom!=oldzoom):
		var new_pos=mouse_in_terms_of_page()
		page_pos+=(new_pos-old_pos)*zoom
		for bruhwhy in sprites:
			bruhwhy.scale=Vector2(zoom,zoom)

func mouse_in_terms_of_page():
	return((get_viewport().get_mouse_position()-page_pos)/zoom)
	
func click_node(node):
	if(node.attatched!=null):
		var victim_con=node.attatched
		victim_con.node1.attatched=null
		victim_con.node2.attatched=null
		connections.erase(victim_con)
		victim_con.free()
		return
	if(bruh==null):
		bruh=node
	else:
		var new_con=connection_class.instantiate()
		new_con.node1=bruh
		new_con.node2=node
		node.attatched=new_con
		bruh.attatched=new_con
		bruh=null
		connections[new_con]=true
		

func get_offset_from_node(node):
	var off_length=5
	if(node.pos.y==2):
		return(Vector2(0,-off_length))
	if(node.pos.y==node.sprite.texture.get_size().y-2):
		return(Vector2(0,+off_length))

func safe_draw_line(line):
	var abovinator:Vector2=Vector2(0,5)
	var pos1:Vector2=line.node1.pos*zoom+line.node1.sprite.position
	var pos2:Vector2=line.node2.pos*zoom+line.node2.sprite.position
	var abovepos1:Vector2=pos1+get_offset_from_node(line.node1)*zoom
	var abovepos2:Vector2=pos2+get_offset_from_node(line.node2)*zoom
	var higher:bool=true
	if(abovepos1.y<abovepos2.y):
		higher=false
	var midpos:Vector2
	if(higher):
		midpos=Vector2(abovepos1.x,abovepos2.y)
	else:
		midpos=Vector2(abovepos2.x,abovepos1.y)
	var vector_vector:Array[Vector2]=[]
	vector_vector.push_back(pos1)
	vector_vector.push_back(abovepos1)
	vector_vector.push_back(midpos)
	vector_vector.push_back(abovepos2)
	vector_vector.push_back(pos2)
	vector_vector_vector.push_back(vector_vector)

func prepare_draw():
	vector_vector_vector=[]
	for line in connections:
		safe_draw_line(line)
	second_pass(0)
		
		
func second_pass(depth:int):
	if(depth>100):
		return
	var sprite_padding=4
	var sp1:Vector2
	var sp2:Vector2
	var sp3:Vector2
	var sp4:Vector2
	var lastpt
	var leftest:float
	var rightest:float
	var hit
	var hit2
	var thisl:float
	var thisr:float
	var newpt: Vector2
	var i
	var point
	var good:bool=true
	var ignore_thresh=4
	for vector_vector in vector_vector_vector:
		lastpt=null
		i=0
		while(i<len(vector_vector)):
			point=vector_vector[i]
			if(lastpt!=null):
				if(point.x==lastpt.x):
					leftest=point.x
					rightest=point.x
					for sprite in sprites:
						sp1=sprite.position
						sp3=sprite.position+sprite.texture.get_size()*zoom
						sp2=sprite.position+Vector2(sprite.texture.get_size().x*zoom,0)
						sp4=sprite.position+Vector2(0,sprite.texture.get_size().y*zoom)
						
						if((sp1.y<point.y and sp3.y>point.y) or (sp1.y<lastpt.y and sp3.y>lastpt.y)):
							continue
						#if(abs(sp1.y-point.y)<ignore_thresh or abs(sp1.y-lastpt.y)<ignore_thresh or abs(sp3.y-point.y)<ignore_thresh or abs(sp3.y-lastpt.y)<ignore_thresh):
							#continue
						sp1-=Vector2(sprite_padding,sprite_padding)
						sp3+=Vector2(sprite_padding,sprite_padding)
						sp2+=Vector2(sprite_padding,-sprite_padding)
						sp4+=Vector2(-sprite_padding,sprite_padding)
						
						hit=Geometry2D.segment_intersects_segment(point,lastpt,sp1,sp2)
						hit2=Geometry2D.segment_intersects_segment(point,lastpt,sp3,sp4)
						if(hit!=null or hit2!=null):
							thisr=sp2.x+1
							thisl=sp1.x-1
						else:
							continue
						if(thisr>rightest):
							rightest=thisr
						if(thisl<leftest):
							leftest=thisl
					if(leftest!=point.x or rightest!=point.x):
						if(abs(point.x-leftest) > abs(rightest-point.x)):
							newpt=Vector2(rightest,point.y)
						else:
							newpt=Vector2(leftest,point.y)
						#splice in newpt between lastpt and the next one
						if(lastpt.y<point.y):
							vector_vector[i-1].x=newpt.x
							vector_vector.insert(i,newpt)
						else:
							vector_vector[i].x=newpt.x
							vector_vector.insert(i,Vector2(newpt.x,lastpt.y))
						good=false
						break
						#break out of this and call self again hoping it is valid this time
			lastpt=point
			i+=1
		if(!good):
			second_pass(depth+1)

func sort_by_y(homie:Vector2,brosef:Vector2):
	return(homie.y>brosef.y)


func _draw():
	draw_rect(Rect2(page_pos,page_dimensions*zoom),Color.ANTIQUE_WHITE)
	if(bruh):
		draw_line(bruh.pos*zoom+bruh.sprite.position,get_viewport().get_mouse_position(),Color.LAWN_GREEN)
	prepare_draw()
	
	for vector_vector in vector_vector_vector:
		var last=null
		var deep_last
		var intersect_points:Array[Vector2]
		var intersect_point
		for point in vector_vector:
			if(last!=null):
				if(last.y==point.y):
					draw_line(last,point,Color.BLACK)
				else:
					intersect_points=[]
					for deep_vector_vector in vector_vector_vector:
						if(deep_vector_vector==vector_vector):
							if(len(vector_vector_vector) == 1):
								draw_line(last,point,Color.BLACK)
							continue
						deep_last=null
						for deep_point in deep_vector_vector:
							if(deep_last!=null):
								intersect_point=Geometry2D.segment_intersects_segment(deep_point,deep_last,last,point)
								if(intersect_point!=null):
									intersect_points.push_back(intersect_point)
							deep_last=deep_point
					if(len(intersect_points)==0):
						draw_line(last,point,Color.BLACK)
					else:
						var higher:bool=true
						if(last.y>point.y):
							higher=false
						var add_vec:Vector2=Vector2(0,10)
						intersect_points.sort_custom(sort_by_y)
						if(higher):
							add_vec*=-1
							intersect_points.reverse()
						var pt1:Vector2=last
						var break_point_nl2=intersect_points.back()
						var break_point_nl=intersect_points.pop_front()
						draw_line(pt1,break_point_nl+add_vec,Color.BLACK)
						draw_line(point,break_point_nl2-add_vec,Color.BLACK)
						pt1=break_point_nl
						for break_point in intersect_points:
							draw_line(pt1-add_vec,break_point+add_vec,Color.BLACK)
							pt1=break_point
			last=point
		
		
	




