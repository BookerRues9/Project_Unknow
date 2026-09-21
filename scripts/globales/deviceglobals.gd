extends Node

# Variables globales para que cualquier script las lea
var fps: int = 0
var gpu_name: String = ""
var system: String = ""
var osver: String = ""
var modelo: String = ""
var renderizador: String = "Unknow"

func _ready() -> void:
	get_device_info()
	verificar_y_aplicar_renderizador_guardado()

# Opcional: Si quieres que los FPS se actualicen constantemente
func _process(_delta: float) -> void:
	fps = Engine.get_frames_per_second()

func get_device_info() -> void:
	fps = Engine.get_frames_per_second()
	gpu_name = RenderingServer.get_video_adapter_name()
	system = OS.get_name() # Ej: "Windows", "Android", "iOS", "Linux", "macOS"
	osver = OS.get_version()
	modelo = OS.get_model_name()
	
	# Obtenemos el método de renderizado actual de Godot ("forward_plus", "mobile", "gl_compatibility")
	var metodo_actual = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	
	# Lógica para definir la variable global 'renderizador' según tus reglas
	if system == "Windows":
		if metodo_actual == "gl_compatibility":
			renderizador = "OpenGL"
		elif metodo_actual == "forward_plus":
			renderizador = "DirectX 12"
		elif metodo_actual == "mobile":
			renderizador = "Vulkan" # O puedes dejarlo como "Incompatible" si prefieres según tu regla
		else:
			renderizador = "Desconocido"
			
	elif system == "Android" or system == "Linux":
		if metodo_actual == "mobile" or metodo_actual == "forward_plus":
			renderizador = "Vulkan"
		elif metodo_actual == "gl_compatibility":
			renderizador = "OpenGL /OpenGL ES"
		else:
			renderizador = "Desconocido"
			
	elif system == "iOS" or system == "macOS":
		if metodo_actual == "mobile" or metodo_actual == "forward_plus":
			# En Apple suele usar Metal por defecto si es Forward+/Mobile, o Vulkan si usa wrappers como MoltenVK
			renderizador = "Metal" 
		elif metodo_actual == "gl_compatibility":
			renderizador = "OpenGL"
		else:
			renderizador = "Desconocido"
	else:
		# Sistemas genéricos o por defecto
		if metodo_actual == "gl_compatibility":
			renderizador = "OpenGL"
		else:
			renderizador = "Vulkan"

# Convertimos la ruta virtual "user://" a la ruta absoluta real del sistema
	var ruta_virtual = "user://"
	var ruta_real_sistema = ProjectSettings.globalize_path(ruta_virtual)

	# Nota sobre OS.get_processor_name(): 
	# En Android/iOS suele devolver una cadena vacía "" o "unknown" porque el sistema no expone esa info fácilmente.
	# Es recomendable validarlo para que no imprima un espacio en blanco feo:
	var procesador = OS.get_processor_name()
	if procesador == "":
		procesador = "CPU Not available / ARM architecture"

	# Imprimimos para verificar en consola
	print("--- Device Info ---")
	print("GPU: " + gpu_name)
	print("OS: " + system + " " + osver)
	print("Model: " + modelo)
	if system == "Windows":	print("Processor: " + procesador) # esto no sirve en android en otras plataformas nose pero lo voy a dejar solo para windows
	print("Godot method render: " + metodo_actual)
	print("Defined render: " + renderizador)
	print("virtual path: " + ruta_virtual)
	print("real path: " + ruta_real_sistema)
	

func verificar_y_aplicar_renderizador_guardado() -> void:
	return 
