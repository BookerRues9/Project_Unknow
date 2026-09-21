extends Node3D

@export var corridor_chunk: PackedScene # Tu escena de trozo de pasillo (un MeshInstance3D de cubos)
@export var chunk_length: float = 10.0 # Longitud del trozo de pasillo
@export var speed: float = 3.0        # Velocidad de movimiento
var chunks: Array[Node3D] = []



func _process(delta: float) -> void:
	for chunk in chunks:
		# Mueve el trozo hacia adelante (hacia la cámara)
		chunk.position.z += speed * delta
		
		# Si el trozo pasa al jugador, lo reciclamos al fondo
		if chunk.position.z >= chunk_length:
			chunk.position.z -= chunk_length * chunks.size()


	

func _on_button_resume_pressed() -> void:
	# Carga tu mapa de prueba principal
	SceneTransition.change_scene("res://mapas/devtest/pruebas_de_mecanicas.tscn")

func _on_button_settings_pressed() -> void:
	print("Abrir ajustes")

func _on_button_exit_pressed() -> void:
	get_tree().quit()
