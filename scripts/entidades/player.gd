extends CharacterBody3D

@export var speed: float = 5.0
const JUMP_VELOCITY = 4.5

# Variable para guardar el NPC que está cerca actualmente
var current_interactable: Area3D = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir: Vector2 = InputManager.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	# --- SISTEMA DE INTERACCIÓN UNIVERSAL ---
	if InputManager.is_action_just_pressed("action_z"):
		indicador.interact()
