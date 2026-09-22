extends CanvasLayer

@onready var panel_container: PanelContainer = $Control/PanelContainer
@onready var rich_text_label: RichTextLabel = $Control/PanelContainer/MarginContainer/RichTextLabel

# Velocidad de escritura (segundos por letra)
@export var text_speed: float = 0.06

var full_text: String = ""
var current_char_index: int = 0
var timer: float = 0.0
var is_typing: bool = false

func _ready() -> void:
	# Aseguramos que empiece limpia
	rich_text_label.text = ""

func _process(delta: float) -> void:
	if not is_typing:
		return
		
	timer += delta
	if timer >= text_speed:
		timer = 0.0
		current_char_index += 1
		
		# Mostramos los caracteres de forma progresiva
		rich_text_label.text = full_text.substr(0, current_char_index)
		
		# Si ya terminó de escribir todo el texto
		if current_char_index >= full_text.length():
			is_typing = false

# Método llamado desde el DialogManager para mostrar un texto
func show_text(new_text: String) -> void:
	full_text = new_text
	current_char_index = 0
	rich_text_label.text = ""
	is_typing = true
	timer = 0.0

# Método por si el jugador presiona "Aceptar" para saltar el tipeo y mostrar todo de golpe
func skip_or_next() -> void:
	if is_typing:
		is_typing = false
		rich_text_label.text = full_text
		current_char_index = full_text.length()
	else:
		# Si ya terminó de leer, cerramos el diálogo
		DialogManager.close_dialog()
		
		
		
