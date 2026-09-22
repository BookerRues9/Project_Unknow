extends Node

var text_data: Dictionary = {}
var is_dialog_active: bool = false

# Referencia opcional a tu escena de UI de la caja de texto
var textbox_scene = preload("res://entidades/UI/Textbox.tscn")
var current_textbox = null

func _ready() -> void:
	load_json_data("res://lang/dialogs.json")

# 1. Cargar el JSON en memoria (al estilo GameMaker)
func load_json_data(path: String) -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			text_data = json.get_data()
			print("Text successfully loaded from JSON")
		else:
			printerr("Error parsing the dialog JSON:", json.get_error_message())
	else:
		printerr("The JSON file was not found at the path: ", path)

# 2. Obtener texto plano por clave (Ideal para menús, botones y títulos)
func get_text(key: String) -> String:
	if text_data.has(key):
		return text_data[key]
	return "string not found:" + key 

# 3. Iniciar un diálogo de NPC (Muestra la caja de texto en pantalla)
func start_dialog(key: String) -> void:
	if is_dialog_active:
		return # Evitar abrir otra caja si ya hay una activa
		
	var dialogue_text = get_text(key)
	is_dialog_active = true
	
	# Instanciamos la caja de texto en la interfaz global
	if not current_textbox:
		current_textbox = textbox_scene.instantiate()
		get_tree().root.add_child(current_textbox)
	
	# Le pasamos el texto a la caja para que lo muestre (con efecto máquina de escribir si quieres)
	current_textbox.show_text(dialogue_text)

# Método para cerrar la caja cuando el jugador presione "Enter" o "Z"
func close_dialog() -> void:
	if current_textbox:
		current_textbox.queue_free()
		current_textbox = null
	is_dialog_active = false
