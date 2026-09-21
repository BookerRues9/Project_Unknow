extends CanvasLayer

var color_rect: ColorRect
var animation_player: AnimationPlayer

func _ready() -> void:
	layer = 128 # Por encima de todo
	# Crear pantalla negra para los fundidos
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0) # Transparente al inicio
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)

# Ahora acepta un parámetro opcional: corruption_level (por defecto 0)
func change_scene(target_scene: String, corruption_level: int = 0) -> void:
	# 1. Fade In (oscurecer pantalla)
	var tween = create_tween()
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	tween.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween.finished
	
	# 2. EFECTOS DE CORRUPCIÓN MIENTRAS ESTÁ EN NEGRO
	await _apply_corruption_effects(corruption_level)
	
	# 3. Cambiar de mapa físicamente
	get_tree().change_scene_to_file(target_scene)
	
	# 4. Fade Out (aclarar pantalla)
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 0.5)
	await tween.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Función que maneja los efectos progresivos según el nivel
func _apply_corruption_effects(level: int) -> void:
	# Pausa base en la oscuridad
	await get_tree().create_timer(0.3).timeout
	
	if level == 0:
		# Nivel 0: Solo transición limpia
		return
		
	elif level == 1:
		# Nivel 1: Screenshake básico
		_trigger_screenshake(15.0, 0.25)
		await get_tree().create_timer(0.3).timeout
		
	elif level == 2:
		# Nivel 2: Screenshake más fuerte + Parpadeo rápido en negro
		_trigger_screenshake(30.0, 0.4)
		for i in range(3):
			color_rect.color.a = 0.4
			await get_tree().create_timer(0.04).timeout
			color_rect.color.a = 1.0
			await get_tree().create_timer(0.04).timeout
			
	elif level >= 3:
		# Nivel 3+: ¡Caos total! Screenshake violento, parpadeo errático y pausa más larga
		_trigger_screenshake(55.0, 0.6)
		for i in range(5):
			color_rect.color.a = randf_range(0.2, 0.9)
			await get_tree().create_timer(0.05).timeout
			color_rect.color.a = 1.0
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(0.4).timeout

# Función auxiliar de Screenshake para la cámara 3D actual
func _trigger_screenshake(intensity: float, duration: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		var original_rot = camera.rotation
		var tween_shake = create_tween()
		for i in range(6):
			var offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * intensity * 0.01
			tween_shake.tween_property(camera, "rotation", original_rot + offset, duration / 6.0)
		tween_shake.tween_property(camera, "rotation", original_rot, duration / 6.0)
