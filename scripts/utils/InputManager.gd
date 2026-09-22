extends Node

# Tipos de dispositivos para saber qué está usando el jugador
enum DeviceType { KEYBOARD, GAMEPAD, TOUCH }
var current_device: DeviceType = DeviceType.KEYBOARD

# Variables para los inputs virtuales (usadas principalmente en móviles)
var virtual_axis_x: float = 0.0
var virtual_axis_y: float = 0.0
var virtual_actions: Dictionary = {}

# Listas opcionales de acciones predefinidas si quieres validarlas por grupo
var registered_actions: Array[String] = ["move_left", "move_right", "move_up", "move_down", "action_z","action_x","action_c","action_pause","action_exit"]

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if current_device != DeviceType.KEYBOARD:
			current_device = DeviceType.KEYBOARD
			print("Switched to mode: Keyboard/Mouse")
			
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if current_device != DeviceType.GAMEPAD:
			current_device = DeviceType.GAMEPAD
			print("Switched to mode: Controller / Gamepad")

# --- FUNCIONES UNIVERSALES ---

func is_action_pressed(action_name: String) -> bool:
	if Input.is_action_pressed(action_name):
		return true
	if virtual_actions.get(action_name, false):
		return true
	return false

func is_action_just_pressed(action_name: String) -> bool:
	if Input.is_action_just_pressed(action_name):
		return true
	return false

# Asegúrate de que tenga el "-> Vector2" al final de la definición
func get_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String) -> Vector2:
	var physical_vector = Input.get_vector(negative_x, positive_x, negative_y, positive_y)
	
	if physical_vector != Vector2.ZERO:
		return physical_vector
		
	return Vector2(virtual_axis_x, virtual_axis_y)

# --- FUNCIONES TÁCTILES ---

func set_virtual_axis(x: float, y: float) -> void:
	virtual_axis_x = x
	virtual_axis_y = y
	if x != 0.0 or y != 0.0:
		current_device = DeviceType.TOUCH

func set_virtual_action(action_name: String, pressed: bool) -> void:
	virtual_actions[action_name] = pressed
	if pressed:
		current_device = DeviceType.TOUCH
