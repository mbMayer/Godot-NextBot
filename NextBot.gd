extends KinematicBody

export (NodePath) var navigation_agent:  = ""
export var face_sprite: StreamTexture
export var audio_source: AudioStream

var explore_points = []
var target = null
var player = null
var navigation:Navigation
var movement_vector = Vector3.ZERO
export var gravity :int = 15
var velocity_y :float = 0.0
export var velocity :float = 2.5 
export var explore_point_list = [NodePath()]

export var ignore_distance :float = 150
var tempo = 60 * 5
var run :bool = false
var path = []
var pathupdate :float = 0.0
export var forget :float = 0.0

export var audio_distance :float = 32

func _ready():
	$AudioStreamPlayer3D.stream = audio_source
	$AudioStreamPlayer3D.max_distance = audio_distance
	$Sprite3D.texture = face_sprite
	navigation = get_node(navigation_agent)
	path.clear()
	explore_points.clear()
	for i in range(explore_point_list.size()):
		explore_points.append(get_parent().get_node("P" + str(i +1)))
	var go = floor(rand_range(0, explore_points.size()))
	target = explore_points[go]
	player = get_parent().get_node("Player")
	$AudioStreamPlayer3D.play()
	pass

func _process(delta):
	tempo -= delta

func _physics_process(delta):
	var distance_to_player = translation.distance_to(player.translation)
	var velocity_scale = velocity * 1.5
	var chasetime = return_time() < 120
	run = false
	if translation.distance_to(target.translation) > 40 or chasetime:
		run = true
	if translation.distance_to(player.translation) < 1.8:
		print("dead")
		get_tree().quit()
	if run:
		velocity_scale = velocity * 2.3
	if is_on_floor():
		if pathupdate > 0:
			pathupdate -= delta
		else :
			if distance_to_player < ignore_distance:
				var ignore = chasetime

				$RayCast.cast_to = player.translation - translation
				$RayCast.force_raycast_update()
				if $RayCast.is_colliding() or ignore:
					if $RayCast.get_collider() == player or ignore:
						target = player
			if forget > 0:
				forget -= 0.2
				if forget <= 0:
					var go_to = floor(rand_range(0, explore_points.size()))
					target = explore_points[go_to]
			pathupdate = 0.2
			path = navigation.get_simple_path(translation, target.translation)
		if path.size() > 2:
			if translation.distance_to(path[2]) > 1:
				movement_vector = translation.direction_to(path[2])
				movement_vector.y = 0

				velocity_y = 0
			else :
				path.remove(0)
		else :
			var go_to = floor(rand_range(0, explore_points.size()))
			target = explore_points[go_to]
			pathupdate = 0
	else :
		velocity_y -= gravity * delta
	move_and_slide(movement_vector * velocity_scale + Vector3(0, velocity_y, 0), Vector3.UP)
	pass

func return_time():
	return tempo
	pass
