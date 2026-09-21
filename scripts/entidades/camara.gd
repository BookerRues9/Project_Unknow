extends Camera3D

@export var player: CharacterBody3D
@export var follow_z: bool = true
@export var follow_height: float = 1.0
@export var follow_distance: float = 6.0
@export var follow_speed: float = 5.0
@export var free_cam_speed: float = 10.0
@export var deadzone_x: float = 4.0

enum CameraMode { FOLLOW, FREE, FIXED }
var current_mode: CameraMode = CameraMode.FOLLOW

var fixed_transform: Transform3D
var mouse_sensitivity: float = 0.003
var free_rotation: Vector3 = Vector3.ZERO
var initial_rotation: Vector3

var saved_camera_positions: Dictionary = {}
var just_switched_to_follow: bool = false # <--- Bandera para detectar el cambio de modo

func _ready() -> void:
	if not player:
		push_warning("No se ha asignado ningún nodo de jugador en el inspector de la cámara.")
	free_rotation = rotation
	initial_rotation = rotation

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_focus_next") or (event is InputEventKey and event.pressed and event.keycode == KEY_TAB):
		if current_mode == CameraMode.FOLLOW:
			current_mode = CameraMode.FREE
			free_rotation = rotation
		elif current_mode == CameraMode.FREE:
			set_mode_follow() # Usamos función para limpiar estados
			
	if current_mode == CameraMode.FREE and event is InputEventMouseMotion:
		free_rotation.y -= event.relative.x * mouse_sensitivity
		free_rotation.x -= event.relative.y * mouse_sensitivity
		free_rotation.x = clamp(free_rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta: float) -> void:
	match current_mode:
		CameraMode.FOLLOW:
			if not is_instance_valid(player):
				return
			
			var target_x = player.global_position.x # Si acabamos de entrar, centramos en X de golpe
			if not just_switched_to_follow:
				target_x = global_position.x
				var x_diff = player.global_position.x - global_position.x
				if abs(x_diff) > deadzone_x:
					target_x = player.global_position.x - (sign(x_diff) * deadzone_x)
			
			var target_z = (player.global_position.z + follow_distance) if follow_z else global_position.z
			var target_pos = Vector3(
				target_x,
				player.global_position.y + follow_height,
				target_z
			)
			
			# Si acabamos de volver a follow, posicionamos al instante para evitar tirones
			if just_switched_to_follow:
				global_position = target_pos
				rotation = initial_rotation
				just_switched_to_follow = false
			else:
				global_position = global_position.lerp(target_pos, follow_speed * delta)
				rotation = rotation.lerp(initial_rotation, follow_speed * delta)

		CameraMode.FREE:
			var dir = Vector3.ZERO
			if Input.is_key_pressed(KEY_W): dir.z -= 1
			if Input.is_key_pressed(KEY_S): dir.z += 1
			if Input.is_key_pressed(KEY_A): dir.x -= 1
			if Input.is_key_pressed(KEY_D): dir.x += 1
			
			rotation = free_rotation
			var motion = (transform.basis * dir.normalized()) * free_cam_speed * delta
			global_position += motion

		CameraMode.FIXED:
			transform = fixed_transform

func trigger_event(id: String) -> void:
	match id:
		_:
			if saved_camera_positions.has(id):
				fixed_transform = saved_camera_positions[id]
				current_mode = CameraMode.FIXED

func save_current_position_for(id: String) -> void:
	saved_camera_positions[id] = global_transform
	print("Posición de cámara guardada para el trigger: ", id)

func return_to_follow() -> void:
	set_mode_follow()

func set_mode_follow() -> void:
	current_mode = CameraMode.FOLLOW
	just_switched_to_follow = true # Activa el reseteo limpio al volver
