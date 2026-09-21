extends CanvasLayer

var label: Label
var panel: PanelContainer

func _ready() -> void:
	layer = 128

	panel = PanelContainer.new()
	# En lugar de un tamaño fijo estricto, dejamos que crezca según el contenido, 
	# o le damos un tamaño mínimo cómodo.
	panel.custom_minimum_size = Vector2(280, 160)
	
	add_child(panel)

	label = Label.new()
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	# Hacemos que el texto se ajuste al ancho del contenedor para que no se salga
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)
	
	# Posicionamos inicialmente
	_actualizar_posicion()

func _process(_delta: float) -> void:
	# Verificamos constantemente el estado global
	if GameManager.debug_mode:
		if not panel.visible:
			panel.show()
		_update_debug_info()
		# Opcional: Actualizar posición por si cambia el tamaño de la ventana (pantalla completa, móvil, etc.)
		_actualizar_posicion()
	else:
		if panel.visible:
			panel.hide()

func _actualizar_posicion() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	# Posición X: Ancho de la pantalla - Ancho del panel - Margen de 20 píxeles
	# Posición Y: 20 píxeles desde arriba
	var panel_width = panel.size.x if panel.size.x > 0 else 280
	panel.position = Vector2(viewport_size.x - panel_width - 20, 20)

func _update_debug_info() -> void:
	# Obtenemos la ruta de la escena actual de forma segura
	var escena_actual = "Desconocida"
	var current_scene = get_tree().current_scene
	if current_scene:
		escena_actual = current_scene.scene_file_path

	label.text = (
		"=== DEBUG INFO ===\n"
		+ "FPS: %d\n" % Deviceglobals.fps
		+ "Scene %s\n" % escena_actual
		+ "GPU: %s\n" % Deviceglobals.gpu_name
		+ "Model: %s\n" % Deviceglobals.modelo
		+ "OS: %s (%s)\n" % [Deviceglobals.system, Deviceglobals.osver]
		+ "Render: %s" % Deviceglobals.renderizador
	)
