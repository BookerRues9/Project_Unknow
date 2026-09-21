extends Node

# Variable global para el modo debug
var debug_mode: bool = true # Ponlo en false por defecto si quieres que empiece apagado

# Opcional: Una señal para avisar a todo el juego cuando cambie el estado
signal debug_toggled(is_active: bool)

func _input(event: InputEvent) -> void:
	# Ejemplo rápido: Si presionas la tecla F3, alternas el modo debug globalmente
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		debug_mode = not debug_mode
		emit_signal("debug_toggled", debug_mode)
		print("Modo debug global: ", "ACTIVADO" if debug_mode else "DESACTIVADO")
