extends Node2D

class_name Mano

signal lanzamiento_fallido(mano, objeto)
signal catch_fallido(mano, objeto)
signal lanzamiento_efectuado(mano, objeto)
signal catch_efectuado(mano, objeto)

var velocidad_mano = 1200

var juguetes = []

# "reposo" | "buscando" | "lanzando" | "ocupada" 
var estado = "reposo"

var buscando = null
@onready var reposo: Vector2 = position

@export var lado = "derecha"

func ocupar():
	estado = "ocupada"
	
func desocupar():
	estado = "reposo"
	#reposo = position
	
func agarrar(juguete: Pelota):
	juguetes.push_back(juguete)
	juguete.sujetar()
	juguete.destruida.connect(func(): juguetes.erase(juguete))
	agregar_marcador()
	
func lanzar(fuerza: Vector2):
	var j = juguetes.pop_back()
	if j:
		j.lanzando()
		j.velocidad = fuerza
		quitar_marcador()
		lanzamiento_efectuado.emit(self, j)
	else:
		lanzamiento_fallido.emit(self, null)
		print("Mano vacía!")


func ir_hacia(hacia: Vector2, con: Vector2, delta: float):
	var direccion = hacia - position
	if direccion.length() > 10:
		position += \
			direccion.normalized() * velocidad_mano * delta +\
			con.normalized() * velocidad_mano * delta


###############
### Process ###
###############

func _process(delta):
	$Label.text = estado
	queue_redraw()
	$Manito.flip_h = lado == "derecha"
	$Palma.flip_h = lado == "derecha"
	$Dedos.flip_h = lado == "derecha"
	posicionar_juguetes()
	if buscando:
		ir_hacia(buscando.position, buscando.velocidad, delta)
	if estado == "reposo":
		ir_hacia(reposo, Vector2.ZERO, delta)

func posicionar_juguetes():
	for i in range(len(juguetes)):
		var j = juguetes[i]
		if len(juguetes) == 1:
			j.position = position
		elif i == 2:
			j.position = position + Vector2(-10, -5)
		elif i == 1: 
			j.position = position + Vector2(10, -5)
		elif i == 0: 
			j.position = position + Vector2(0, -20)
		else:
			j.position = position

func _draw():
	draw_circle(Vector2.ZERO, 10, Color.DARK_RED)

#################
### Listeners ###
#################

func _on_alcance(area):
	if area is Pelota and area.is_libre:
		agarrar(area)
		catch_efectuado.emit(self, area)
		buscando = null
		estado = "reposo" if not(estado == "lanzando") else "lanzando"

func _on_influencia(area):
	if area is Pelota and area.is_libre:
		estado = "buscando"
		buscando = area

func _off_influencia(area):
	if buscando == area:
		catch_fallido.emit(self, area)
		buscando = null
		estado == "reposo" if not(estado == "lanzando") else "lanzando"


##################
### Marcadores ###
##################

@onready var marcadores = [$Marcadores/M1, $Marcadores/M2, $Marcadores/M3, $Marcadores/M4, $Marcadores/M5]
var ms = 0

func agregar_marcador():
	ms += 1
	ms = clamp(ms, 0, 5)
	marcadores[ms - 1].visible = true
	
func quitar_marcador():
	marcadores[ms - 1].visible = false
	ms -= 1
	ms = clamp(ms, 0, 5)


func _on_influencia_mouse_entered():
	print("Entrando influencia")


func _on_influencia_mouse_exited():
	print("Saliendo influencia")
