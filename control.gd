class_name control extends Node2D

@export var sprite_class : PackedScene
@export var connection_class : PackedScene
@export var state_scene : PackedScene
@export var node_scene : PackedScene
@export var elixer_tex : Texture

var page_pos:Vector2=Vector2(500,200)
var page_dimensions:Vector2 = Vector2(1100,700)
var zoom:float=1
var zoom_min:float=0.1
var zoom_max:float=20
var zoom_mod:float=0.1
var holding:bool=false
var holding_position:Vector2
var sprites:Array[Sprite_class] = []
var connections:Dictionary = {}
var mouse_pos:Vector2
var bruh:Node_connection=null
var vector_vector_vector
var edit_list:Array[state_class]=[]
var undo_list:Array[state_class]=[]

func save_state():
	var this_state=state_scene.instantiate()
	sprite_copy(self,this_state)
	return(this_state)
	
func sprite_copy(source_obj,destination_obj):
	var source_array:Array[Sprite_class]=source_obj.sprites
	var destination_array:Array[Sprite_class]=destination_obj.sprites
	var dupe_sprite:Sprite_class
	var dupe_conncetion
	var i:int
	var dupe_node
	var node_translation:Dictionary={null:null}
	for sprite in source_array:
		dupe_sprite=sprite_class.instantiate()
		dupe_sprite.pos=Vector2(sprite.pos.x,sprite.pos.y)
		dupe_sprite.texture=sprite.texture
		for node in sprite.nodes:
			dupe_sprite.add_node(Vector2(node.pos.x,node.pos.y))
			if(node.attatched!=null):
				dupe_node=dupe_sprite.nodes.back()
				node_translation[node]=dupe_node
			
		destination_array.push_back(dupe_sprite)
	for connection in source_obj.connections:
		dupe_conncetion=connection_class.instantiate()
		dupe_conncetion.node1=node_translation[connection.node1]
		dupe_conncetion.node2=node_translation[connection.node2]
		destination_obj.connections[dupe_conncetion]=true
		if(dupe_conncetion.node1!=null):
			dupe_conncetion.node1.attatched=dupe_conncetion
			dupe_conncetion.node2.attatched=dupe_conncetion
func undo():
	undo_list.push_front(edit_list.pop_back())
	load_state(edit_list.back())
	
	
func load_state(new_state):
	for sprite in sprites:
		sprite.free()
	sprites=[]
	connections={}
	sprite_copy(new_state,self)
	for sprite in sprites:
		sprite.parent=self
		add_child(sprite)
		sprite.scale=Vector2(zoom,zoom)
		
		
	
	edit_redraw()

func redo():
	var new_state=undo_list.pop_front()
	edit_list.push_back(new_state)
	load_state(new_state)
	
	
func register_edit():
	undo_list=[]
	edit_list.push_back(save_state())
	
	edit_redraw()

func edit_redraw():
	prepare_draw()

# Called when the node enters the scene tree for the first time.
func _ready():
	register_edit()
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("undo"):
		if(len(edit_list)==1): return
		undo()
	if event.is_action_pressed("redo"):
		if(len(undo_list)==0): return
		redo()
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
		this_sprite.add_node(Vector2(16,2))
		this_sprite.parent=self
		register_edit()
	if event.is_action_pressed("key_9"):
		var this_sprite=sprite_class.instantiate()
		this_sprite.position=Vector2(200,200)
		this_sprite.scale=Vector2(zoom,zoom)
		add_child(this_sprite)
		sprites.push_back(this_sprite)
		this_sprite.texture=elixer_tex
		this_sprite.add_node(Vector2(16,2))
		this_sprite.add_node(Vector2(16,30))
		this_sprite.parent=self
		register_edit()
	
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
		register_edit()
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
		register_edit()

func get_offset_from_node(node):
	var off_length=5
	if(node.pos.y==2):
		return(Vector2(0,-off_length))
	if(node.pos.y==node.sprite.texture.get_size().y-2):
		return(Vector2(0,+off_length))

func safe_draw_line(line):
	var abovinator:Vector2=Vector2(0,5)
	var pos1:Vector2=line.node1.pos+line.node1.sprite.pos
	var pos2:Vector2=line.node2.pos+line.node2.sprite.pos
	var abovepos1:Vector2=pos1+get_offset_from_node(line.node1)
	var abovepos2:Vector2=pos2+get_offset_from_node(line.node2)
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
	if(depth>10):
		print("can't find working path")
		return
	var sprite_padding=1
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
	var epsilon:float=0.0001
	for vector_vector in vector_vector_vector:
		lastpt=null
		i=0
		while(i<len(vector_vector)-1):
			point=vector_vector[i]
			if(lastpt!=null):
				var goalc:float
				var startc:float
				var lastleft:float
				var lastright:float
				var testc:float
				var loops:int=0
				var c1:float
				var c2:float
				var test_point1:Vector2
				var test_point2:Vector2
				var rscore:float
				var lscore:float
				var vertical:bool
				if(point.x==lastpt.x): #vertical version
					vertical=true
					c1=point.y
					c2=lastpt.y
					testc=point.x
					startc=point.x
					if(lastpt.y<point.y):
						goalc=vector_vector[i-2].x
					else:
						goalc=vector_vector[i+1].x
				else: #horizontal version
					lastpt=point
					i+=1
					continue # this no work good
					vertical=false
					c1=point.x
					c2=lastpt.x
					testc=point.y
					startc=point.y
					if(lastpt.x<point.x):
						goalc=vector_vector[i-2].y
					else:
						goalc=vector_vector[i+1].y
				leftest=testc
				rightest=testc
				while(true):
					if(loops>1000):
						print("no valid line pathing - big sad")
						break
					lastleft=leftest
					lastright=rightest
					for sprite in sprites: #test all the sprites for hitting testc
						sp1=sprite.pos
						sp3=sprite.pos+sprite.texture.get_size()
						sp2=sprite.pos+Vector2(sprite.texture.get_size().x,0)
						sp4=sprite.pos+Vector2(0,sprite.texture.get_size().y)
						var npos:Vector2
						var breakout:bool=false
						for node in sprite.nodes:
							npos=node.pos+sprite.pos
							var a=npos.distance_to(point)
							var b=npos.distance_to(lastpt)
							if(a<epsilon or b<epsilon):
								breakout=true
								break
						if(breakout):
							continue
						#if((sp1.y<point.y and sp3.y>point.y) or (sp1.y<lastpt.y and sp3.y>lastpt.y)):
							#continue
						#if(abs(sp1.y-point.y)<ignore_thresh or abs(sp1.y-lastpt.y)<ignore_thresh or abs(sp3.y-point.y)<ignore_thresh or abs(sp3.y-lastpt.y)<ignore_thresh):
							#continue
						sp1-=Vector2(sprite_padding,sprite_padding)
						sp3+=Vector2(sprite_padding,sprite_padding)
						sp2+=Vector2(sprite_padding,-sprite_padding)
						sp4+=Vector2(-sprite_padding,sprite_padding)
						if(vertical):
							test_point1=Vector2(testc,c1)
							test_point2=Vector2(testc,c2)
							hit=Geometry2D.segment_intersects_segment(test_point1,test_point2,sp1,sp2)
							hit2=Geometry2D.segment_intersects_segment(test_point1,test_point2,sp3,sp4)
							if(hit!=null or hit2!=null):
								thisr=sp2.x+1
								thisl=sp1.x-1
							else:
								continue
						else:
							test_point1=Vector2(c1,testc)
							test_point2=Vector2(c2,testc)
							hit=Geometry2D.segment_intersects_segment(test_point1,test_point2,sp1,sp4)
							hit2=Geometry2D.segment_intersects_segment(test_point1,test_point2,sp2,sp3)
							if(hit!=null or hit2!=null):
								thisr=sp3.y+1
								thisl=sp1.y-1
							else:
								continue
						if(thisr>rightest):
							rightest=thisr
						if(thisl<leftest):
							leftest=thisl
					if(leftest!=lastleft or rightest!=lastright):
						lscore=abs(goalc-leftest)+abs(startc-leftest)
						rscore=abs(goalc-rightest)+abs(startc-rightest)
						if(lscore > rscore):
							testc=rightest
						else:
							testc=leftest
					else:
						break
						
					
				if(testc!=startc):
					if(vertical):
						newpt=Vector2(testc,point.y)
					else:
						newpt=Vector2(point.x,testc)
					#splice in newpt between lastpt and the next one
					if(c2<c1):
						if(vertical):
							vector_vector[i-1].x=newpt.x
						else:
							vector_vector[i-1].y=newpt.y
						vector_vector.insert(i,newpt)
					else:
						if(vertical):
							vector_vector[i].x=newpt.x
							vector_vector.insert(i,Vector2(newpt.x,lastpt.y))
						else:
							vector_vector[i].y=newpt.y
							vector_vector.insert(i,Vector2(lastpt.x,newpt.y))
						
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
	
	for vector_vector in vector_vector_vector:
		var last=null
		var deep_last
		var intersect_points:Array[Vector2]
		var intersect_point
		var multibreak1:Vector2
		var multibreak2:Vector2
		for point in vector_vector:
			if(last!=null):
				if(last.y==point.y):
					draw_line(last*zoom+page_pos,point*zoom+page_pos,Color.BLACK)
				else:
					intersect_points=[]
					for deep_vector_vector in vector_vector_vector:
						if(deep_vector_vector==vector_vector):
							if(len(vector_vector_vector) == 1):
								var a=1
								#draw_line(last,point,Color.BLACK)
							continue
						deep_last=null
						for deep_point in deep_vector_vector:
							if(deep_last!=null):
								intersect_point=Geometry2D.segment_intersects_segment(deep_point,deep_last,last,point)
								if(intersect_point!=null):
									intersect_points.push_back(intersect_point)
							deep_last=deep_point
					if(len(intersect_points)==0):
						draw_line(last*zoom+page_pos,point*zoom+page_pos,Color.BLACK)
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
						
						#check to make sure that lines don't get drawn stupidly at this zoom level
						var p1test:Vector2=pt1*zoom+page_pos
						var p2test:Vector2=break_point_nl*zoom+page_pos +add_vec
						
						var p3test:Vector2=point*zoom+page_pos
						var p4test:Vector2=break_point_nl2*zoom+page_pos -add_vec
						
						var l1good:bool=!higher
						var l2good:bool=!higher
						if(p1test<p2test):
							l1good=!l1good
						if(p3test>p4test):
							l2good=!l2good
						if(l1good):
							draw_line(p1test,p2test,Color.BLACK)
						if(l2good):
							draw_line(p3test,p4test,Color.BLACK)
						pt1=break_point_nl
						for break_point in intersect_points:
							multibreak1=pt1*zoom+page_pos -add_vec
							multibreak2=break_point*zoom+page_pos +add_vec
							l1good=!higher
							if(multibreak1<multibreak2):
								l1good=!l1good
							if(l1good):
								draw_line(multibreak1,multibreak2,Color.BLACK)
							pt1=break_point
			last=point
		
	#draw edit history
	var dx:int=100
	var width:int=40
	var padding:int=5
	var dy:int=20
	for who_cares in edit_list:
		draw_rect(Rect2(dx,dy,width,width),Color.NAVY_BLUE)
		dx+=width+padding
	dx-=width+padding
	draw_rect(Rect2(dx-1,dy-1,width+2,width+2),Color.GHOST_WHITE,false)
	dx+=width+padding
	for who_cares in undo_list:
		draw_rect(Rect2(dx,dy,width,width),Color.SLATE_GRAY)
		dx+=width+padding




