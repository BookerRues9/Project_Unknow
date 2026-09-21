extends Area3D

@export var interaction_text: String = "Hablar"
@onready var indicator: Node3D = $MeshInstance3D # Asegúrate de que este sea el nombre exacto de tu nodo visual

var initial_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	# Conexión explícita de señales por código
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if indicator:
		initial_y = indicator.position.y # Guarda la altura base del cono
		indicator.visible = false

func _process(delta: float) -> void:
	# Solo anima si el indicador está visible
	if indicator and indicator.visible:
		time_passed += delta * 6.0
		indicator.position.y = initial_y + (sin(time_passed) * 0.15)

func _on_body_entered(body: Node3D) -> void:
	print("--- ALGO ENTRÓ AL ÁREA: ", body.name, " ---")
	if body.is_in_group("Player"):
		print("¡Es el jugador! Mostrando indicador.")
		if indicator:
			indicator.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("El jugador salió del área.")
		if indicator:
			indicator.visible = false
			time_passed = 0.0 # Reinicia el tiempo para el próximo rebote
