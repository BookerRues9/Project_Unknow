extends Area3D

@export var trigger_id: String = "zona_1" # ID único para el switch/case
@export var target_camera: Camera3D   # Arrastra tu cámara principal aquí
@export var player: CharacterBody3D   # Arrastra tu nodo Player aquí

var player_inside: bool = false

@onready var mesh_visual: MeshInstance3D = $MeshInstance3D  # Cambia el nombre si tu nodo se llama distinto

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Oculta el mesh en el juego, manteniendo su visibilidad en el editor
	if mesh_visual:
		mesh_visual.visible = false

func _process(_delta: float) -> void:
	# Si el jugador está en el trigger, y presionas 'X', guarda la posición actual de la cámara para este ID
	if player_inside and Input.is_key_pressed(KEY_X):
		if target_camera:
			target_camera.save_current_position_for(trigger_id)
			print("camara guardada")

func _on_body_entered(body: Node3D) -> void:
	if body == player or body.is_in_group("player"):
		print("jugador entro al trigger")
		player_inside = true
		if target_camera:
			target_camera.trigger_event(trigger_id)

func _on_body_exited(body: Node3D) -> void:
	if body == player or body.is_in_group("player"):
		print("jugador salio del trigger")
		player_inside = false
		if target_camera:
			target_camera.return_to_follow()
