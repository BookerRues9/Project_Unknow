extends Node

# Variable estática global para la ruta del archivo
static var log_file_path: String = "user://game_logs.txt"

# Definimos la clase interna que hereda del Logger nativo de Godot
class CustomLogger extends Logger:
	var mutex: Mutex = Mutex.new() # Seguridad para hilos (threads)

	func _log_message(message: String, error: bool) -> void:
		mutex.lock()
		# Usamos la clase principal para acceder de forma segura a la ruta
		var file = FileAccess.open(logger.log_file_path, FileAccess.READ_WRITE)
		if file:
			file.seek_end()
			var timestamp = Time.get_time_string_from_system()
			var prefix = "[ERROR] " if error else "[LOG] "
			file.store_string("[" + timestamp + "] " + prefix + message)
			file.close()
		mutex.unlock()

	func _log_error(
			function: String,
			file_name: String,
			line: int,
			code: String,
			rationale: String,
			editor_notify: bool,
			error_type: int,
			script_backtraces: Array[ScriptBacktrace]
	) -> void:
		mutex.lock()
		var file = FileAccess.open(logger.log_file_path, FileAccess.READ_WRITE)
		if file:
			file.seek_end()
			var timestamp = Time.get_time_string_from_system()
			file.store_string("[" + timestamp + "] [GDScript Error] in " + file_name + ":" + str(line) + " -> " + rationale + "\n")
			file.close()
		mutex.unlock()

# Usamos _init() para configurar la ruta según la plataforma y registrar el logger
func _init() -> void:
	var os_name = OS.get_name()
	
	# Lógica personalizada por plataforma usando rutas absolutas o virtuales (`user://`)
	match os_name:
		"Android":
			# Opción A: Usar user:// (Godot lo traduce automáticamente a /storage/emulated/0/Android/data/tu.paquete/files/)
			#log_file_path = "user://game_logs.txt"
			
			# Opción B (Si prefieres una ruta absoluta explícita en la SD interna):
			log_file_path = "/storage/emulated/0/Android/data/com.example.project_unknow/files/game_logs.txt"
			
		"Windows":
			# En Windows puedes guardarlo en user:// o en una ruta fija si lo deseas
			log_file_path = "user://game_logs.txt"
			
		"Linux", "macOS":
			log_file_path = "user://game_logs.txt"
			
		_:
			log_file_path = "user://game_logs.txt"

	# Inicializamos el archivo limpiándolo al arrancar
	var f = FileAccess.open(log_file_path, FileAccess.WRITE)
	if f:
		f.store_string("=== NATIVE GAME LOGS START (" + os_name + ") ===\n")
		f.close()
		print("Custom Logger started in: ", ProjectSettings.globalize_path(log_file_path))
	
	# Registramos nuestra clase personalizada en el sistema operativo de Godot
	OS.add_logger(CustomLogger.new())
