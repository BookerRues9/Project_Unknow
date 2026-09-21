extends Node3D

@export var enemy_scene: PackedScene = preload("res://entidades/enemy.tscn") # Ajusta tu ruta si es diferente
@export var cantidad_enemigos: int = 2

func _ready():
	# Esperamos un frame para asegurarnos de que el jugador ya cargó en la escena
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("¡No se encontró al jugador para calcular el spawn!")
		return
	
	# Recolectamos todos los Marker3D hijos de un nodo llamado "PuntosDeSpawn"
	# (O puedes buscarlos por grupo si prefieres ponerlos por todo el mapa)
	var markers = []
	if has_node("PuntosDeSpawn"):
		for child in $PuntosDeSpawn.get_children():
			if child is Marker3D:
				markers.append(child)
	
	if markers.is_empty():
		print("¡No hay marcadores de spawn configurados!")
		return
	
	# Ordenamos los marcadores según qué tan lejos/cerca están del jugador
	# Para buscar un susto, podemos ordenar de menor a mayor distancia
	markers.sort_custom(func(a, b):
		var dist_a = a.global_position.distance_to(player.global_position)
		var dist_b = b.global_position.distance_to(player.global_position)
		return dist_a < dist_b
	)
	
	# Spawneamos los enemigos usando los marcadores más cercanos (dejando los más lejanos o eligiendo aleatorios entre los cercanos)
	for i in range(min(cantidad_enemigos, markers.size())):
		# Tomamos uno de los marcadores cercanos (por ejemplo, entre los 3 más cercanos para que no salgan encima de ti exactamente, sino a la vuelta de la esquina)
		var spawn_point = markers[i] 
		
		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = spawn_point.global_position
		print("¡Enemigo spawneado en marcador cercano!")
