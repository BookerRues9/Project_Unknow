extends Control

@onready var main_options: Control = $MainOptionsContainer
@onready var settings_menu: Control = $SettingsContainer

@onready var lbl_resolucion: Label = $SettingsContainer/TabContainer/Graficos/FilaRes/ValResolucion
@onready var lbl_renderizador: Label = $SettingsContainer/TabContainer/Graficos/FilaRender/ValRenderizador

var lista_resoluciones: Array = ["1280x720", "1920x1080", "800x600", "Pantalla Completa"]
var indice_res_actual: int = 0

var lista_renderizadores: Array = ["gl_compatibility", "mobile", "forward_plus"]
var indice_rend_actual: int = 0

var screen_width: float = 0.0

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	custom_minimum_size = viewport_size
	screen_width = viewport_size.x
	
	settings_menu.position.x = screen_width
	
	# Cargar ajustes guardados previamente (esto también aplica la resolución guardada)
	cargar_ajustes()
	
	actualizar_texto_resolucion()
	actualizar_texto_renderizador()

# --- ANIMACIONES DEL MENÚ ---

func _on_settings_pressed() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_options, "position:x", -screen_width, 0.5)
	tween.tween_property(settings_menu, "position:x", 0.0, 0.5)

func _on_back_pressed() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_options, "position:x", 0.0, 0.5)
	tween.tween_property(settings_menu, "position:x", screen_width, 0.5)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://mapas/devtest/pruebas_de_mecanicas.tscn.tscn")
	print("Iniciando juego...")

func _on_exit_pressed() -> void:
	get_tree().quit()


# --- LÓGICA DE LAS FLECHAS (RESOLUCIÓN) ---

func _on_btn_res_izq_pressed() -> void:
	indice_res_actual = (indice_res_actual - 1 + lista_resoluciones.size()) % lista_resoluciones.size()
	actualizar_texto_resolucion()
	aplicar_resolucion_actual() # Se aplica de inmediato al hacer clic

func _on_btn_res_der_pressed() -> void:
	indice_res_actual = (indice_res_actual + 1) % lista_resoluciones.size()
	actualizar_texto_resolucion()
	aplicar_resolucion_actual() # Se aplica de inmediato al hacer clic

func actualizar_texto_resolucion() -> void:
	var res_seleccionada = lista_resoluciones[indice_res_actual]
	lbl_resolucion.text = res_seleccionada

func aplicar_resolucion_actual() -> void:
	var opcion = lista_resoluciones[indice_res_actual]
	
	if opcion == "Pantalla Completa":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# Si estaba en pantalla completa, lo regresamos a ventana normal
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
		var partes = opcion.split("x")
		var w = partes[0].to_int()
		var h = partes[1].to_int()
		DisplayServer.window_set_size(Vector2i(w, h))
		print("Resolución aplicada: ", w, "x", h)


# --- LÓGICA DE LAS FLECHAS (RENDERIZADOR) ---

func _on_btn_rend_izq_pressed() -> void:
	indice_rend_actual = (indice_rend_actual - 1 + lista_renderizadores.size()) % lista_renderizadores.size()
	actualizar_texto_renderizador()

func _on_btn_rend_der_pressed() -> void:
	indice_rend_actual = (indice_rend_actual + 1) % lista_renderizadores.size()
	actualizar_texto_renderizador()

func actualizar_texto_renderizador() -> void:
	var rend_seleccionado = lista_renderizadores[indice_rend_actual]
	lbl_renderizador.text = rend_seleccionado


# --- GUARDAR Y CARGAR AJUSTES ---

func guardar_ajustes() -> void:
	var config = ConfigFile.new()
	
	config.set_value("graficos", "resolucion_index", indice_res_actual)
	config.set_value("graficos", "renderizador", lista_renderizadores[indice_rend_actual])
	
	config.save("user://settings.cfg")
	print("¡Ajustes guardados en user://settings.cfg!")
	print("Ruta absoluta del archivo:", ProjectSettings.globalize_path("user://settings.cfg"))

func cargar_ajustes() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		indice_res_actual = config.get_value("graficos", "resolucion_index", 0)
		var rend_guardado = config.get_value("graficos", "renderizador", "gl_compatibility")
		
		indice_rend_actual = lista_renderizadores.find(rend_guardado)
		if indice_rend_actual == -1: indice_rend_actual = 0
		
		# Aplicar la resolución cargada al arrancar el juego
		aplicar_resolucion_actual()
		
		print("Ajustes cargados exitosamente.")

func _on_save_and_back_pressed() -> void:
	guardar_ajustes()
	print(ProjectSettings.globalize_path("user://settings.cfg"))
	_on_back_pressed()


func _on_resume_pressed() -> void:
	SceneTransition.change_scene("res://mapas/devtest/pruebas_de_mecanicas.tscn", 0)
	print("boton de resume pibe")
