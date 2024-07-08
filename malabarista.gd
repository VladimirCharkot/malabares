extends Node2D

@export var juguete: PackedScene
@onready var mano_activa = $ManoDer
@onready var mano_pasiva = $ManoIzq

signal lanzada

var step = 0

# Mover la mano activa hacia el centro, lanzar, volver
func simple(mano: Mano, lanzamiento: Vector2):
	if lanzamiento == Vector2.ZERO: return
	var dx = -mano.position.x/3		# Un tercio de camino desde reposo hasta centro
	var dy = 30
	var f = lanzamiento.reflect(Vector2.UP) if dx < 0 else lanzamiento
	await mover_mano(mano, Vector2(dx/2, dy), 0.1)
	await mover_mano(mano, Vector2(dx/2, -dy), 0.1)
	mano.lanzar(f)
	await mover_mano(mano, Vector2(-dx, 0), 0.1)
	lanzada.emit()
	
func multiplex(mano: Mano, lanzamientos):
	print("Multiplex recibiendo:")
	print(lanzamientos)
	var dx = -mano.position.x/3		# Un tercio de camino desde reposo hasta centro
	var dy = 30
	await mover_mano(mano, Vector2(dx/2, dy), 0.2)
	await mover_mano(mano, Vector2(dx/2, -dy), 0.2)
	var fs = lanzamientos.map(func (l): return l.reflect(Vector2.UP) if dx < 0 else l)
	for f in fs:
		if not(f == Vector2.ZERO):
			mano.lanzar(f)
	await mover_mano(mano, Vector2(-dx, 0), 0.2)
	lanzada.emit()

func sincro(l1, l2):
	if typeof(l1) == typeof([]):
		multiplex(mano_activa, l1)
	else:
		simple(mano_activa, l1)
	if typeof(l2) == typeof([]):
		multiplex(mano_pasiva, l2)
	else:
		simple(mano_pasiva, l2)
	await lanzada
#func mover_der(hacia: Vector2, duracion: float):
	#mover_mano($ManoDer, hacia, duracion, null)
#
#func mover_izq(hacia: Vector2, duracion: float):
	#mover_mano($ManoIzq, hacia, duracion, null)
	
	
#func lanzar_der(desde: Vector2, f: Vector2):
	#lanzar($ManoDer, desde, f)
	#
#func lanzar_izq(desde: Vector2, f: Vector2):
	#lanzar($ManoIzq, desde, f)
	
#func lanzar(mano: Node2D, desde: Vector2, f: Vector2):
	#mover_mano(mano, desde - mano.position, 0.4, func(): mano.lanzar(f))

#func mover_y_lanzar(mano: Node2D, desde: Vector2, t: float, f: Vector2 = Vector2.ZERO):
	#if f.length():
		#mover_mano(mano, desde - mano.position, t, func(): mano.lanzar(f))
	#else:
		#mover_mano(mano, desde - mano.position, t, null)
	

func mover_mano(mano: Node2D, delta: Vector2, duracion: float):
	var tween = get_tree().create_tween()
	mano.ocupar()
	tween.tween_property(mano, "position", mano.position + delta, duracion).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(mano.desocupar)
	await tween.finished
	


func _process(delta):
	queue_redraw()
	
func _draw():
	draw_arc(mano_activa.position, 60, 0, 2 * PI, 30, Color(Color.AQUA, 0.2))

func _ready():
	crear_pelotas(5)
		
func atajar(delta: float,
			mano: Node2D, 
			ruta: PathFollow2D):
	if ruta.progress_ratio < 0.9:
		ruta.progress_ratio += delta 
		mano.position = ruta.position
	else: 
		mano.estado = "buscando"
		ruta.progress_ratio = 0

func crear_pelotas(n):
	for i in range(n):
		print("Creando pelota...")
		var j = juguete.instantiate()
		j.is_libre = false
		add_child(j)
		mano_activa.agarrar(j)
		swap()
	swap()

func swap():
	mano_activa = $ManoDer if mano_activa == $ManoIzq else $ManoIzq
	mano_pasiva = $ManoDer if mano_activa == $ManoIzq else $ManoIzq

func _on_mano_der_lanzamiento_efectuado(mano, objeto):
	pass
	#print("Lanzamiento der")
	#$ManoIzq.buscando = objeto

func _on_mano_izq_lanzamiento_efectuado(mano, objeto):
	pass
	#print("Izquierda lanzó ", objeto)
	#$ManoDer.buscando = objeto


func _on_area_2d_mouse_entered():
	print("tuvieja")
