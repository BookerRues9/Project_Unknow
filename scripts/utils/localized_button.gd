extends Button

# Esta clave aparecerá en el inspector de Godot para que elijas qué texto mostrar
@export var text_key: String = "setting_magic"

func _ready() -> void:
	# Al arrancar, el botón busca su texto en el JSON a través del DialogManager
	update_button_text()

func update_button_text() -> void:
	text = DialogManager.get_text(text_key)
