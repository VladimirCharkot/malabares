extends Area2D

class_name Pelota

signal destruida

@export var gravedad = Vector2(0, 2000)
var velocidad = Vector2(0, 0)
var is_libre = true		# Habilita ser agarrada
var is_suelta = true	# Aplica gravedad
var focus = true	 	# Debug

var dt = 0

func sujetar():
	is_libre = false
	is_suelta = false
	
func lanzando():
	dt = 0
	libre()
	suelta()
	
func libre():
	is_libre = true
	
func suelta():
	is_suelta = true

func _physics_process(delta):
	if is_suelta:
		velocidad += gravedad * delta
		position += velocidad * delta
		dt += delta * 1000

func _process(delta):
	if Params.labelFactor:
		$LabelDt.text = "dt: " + str(snapped(dt / Params.dt, 0.01))
	else:
		$LabelDt.text = "dt: " + str(snapped(dt, 1))


func _on_visible_on_screen_notifier_2d_screen_exited():
	if position.y > 0: 
		destruida.emit()
		queue_free()


func _on_mouse_entered():
	focus = true
	print("focused")

func _on_mouse_exited():
	focus = false
	print("unfocused")
