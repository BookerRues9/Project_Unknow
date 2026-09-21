extends CharacterBody3D

@export var speed: float = 3.5
var player: Node3D = null

func _ready():
	await get_tree().process_frame
	if get_tree().has_group("Player"):
		player = get_tree().get_first_node_in_group("Player")
		print("¡Jugador encontrado por el enemigo!")
	else:
		print("¡ALERTA: No hay ningun nodo en el grupo 'Player'!")
	
	$Area3D.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if not player:
		return
	
	# Mantenemos la misma altura Y del enemigo para que no flote hacia el cielo ni caiga al suelo
	var target_pos = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	var direction = global_position.direction_to(target_pos)
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = 0.0 # <-- Evitamos que caiga al vacío por ahora
	
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# ¡Te atrapó! Cambiamos a la escena usando tu ruta
		SceneTransition.change_scene("res://mapas/devtest/principal.tscn") # (Asegúrate de ponerle .tscn si hace falta)
