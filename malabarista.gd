extends Node2D

@export var juguete: PackedScene
@onready var mano_activa = $ManoDer
@onready var mano_pasiva = $ManoIzq

var secuencia = []
var loopeando = false

# Si la anterior fue sincro hay que esperar un tiempo más
var did_sincro = false

var freestyle = true
var lanzamiento = 5

signal lanzada
signal comando_ejecutado

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
	

func mover_mano(mano: Node2D, delta: Vector2, duracion: float):
	var tween = get_tree().create_tween()
	mano.ocupar()
	tween.tween_property(mano, "position", mano.position + delta, duracion).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(mano.desocupar)
	await tween.finished
	

func _input(event):
	
	if freestyle and event is InputEventKey and event.pressed:
				
		if event.keycode == KEY_LEFT:
			var l = $Lanzamientos.lanzamiento(lanzamiento, 240)
			await simple($ManoIzq, l)
			swap()
		
		if event.keycode == KEY_RIGHT:
			var l = $Lanzamientos.lanzamiento(lanzamiento, 240)
			await simple($ManoDer, l)
			swap()


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

func encolar(comando):
	secuencia.push_back(comando)

func _on_base_timeout():
	if did_sincro: 
		did_sincro = false
		return 
	var comando = secuencia.pop_front()
	if comando:
		delegar(comando)
		swap()
	if loopeando:
		secuencia.push_back(comando)
		
# Recibe un frame y delega la acción al malabarista
func delegar(frame):
	
	if frame["tipo"] == "simple":
		var l = $Lanzamientos.traducir(frame["lanz"])
		#var l = $Lanzamientos.lanzamiento(int(frame["lanz"]), 260)
		await simple(mano_activa, l)

	if frame["tipo"] == "multiplex":
		var ls = frame["lanz"].map(func (l): return $Lanzamientos.traducir(l))
		await multiplex(mano_activa, ls)

	if frame["tipo"] == "sincro":
		var m_activa = frame["lanz"][0]
		var m_inactiva = frame["lanz"][1]
		did_sincro = true
		await sincro(
			$Lanzamientos.traducir(m_activa["lanz"]), 
			$Lanzamientos.traducir(m_inactiva["lanz"])
		)
		
	comando_ejecutado.emit()

func aparecer():
	var t = create_tween() 
	t.tween_property($Malabarista, "modulate", Color.WHITE, 1)
	$Base.start()
	

func set_secuenciando(on: bool):
	if on:
		$Base.start()
	else:
		$Base.stop()

func _on_area_2d_mouse_entered():
	print("tuvieja")
