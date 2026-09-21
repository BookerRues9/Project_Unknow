extends CharacterBody3D

@export var speed: float = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta: float) -> void:
	# Añadir gravedad si es necesario (quitar si es movimiento tipo top-down / 2.5D)
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Capturar la entrada de WASD / flechas
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
