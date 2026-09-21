extends Area3D

@export_file("*.tscn") var next_scene: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and next_scene:
		# Llama al sistema global de transición y le pasa la ruta del nuevo mapa
		#SceneTransition.change_scene(next_scene)
		SceneTransition.change_scene(next_scene, 2)
		
