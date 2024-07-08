extends Control

signal zoom(level)

var secuencia = []

var teclas_numeros = [KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]
#var secuencia_string = "(6x4)(6x4)(6x4)(6x4)(4x6x)(4x6x)6456456456456636637447447537536756167561"
var secuencia_string = "(6x4)(6x4)"
#var secuencia_string = "5"
var secuencia_ingresada = ""
var secuenciando = false
var i_secuencia = 0
var lanzamiento = "5"

func _ready():
	secuencia = parsear_secuencia(secuencia_string)
	
func _process(delta):
	if secuenciando:
		$Display.text = "Secuencia: " + secuencia_string
		$Ingresando.text = secuencia_ingresada
	else:
		$Display.text = "Lanzamiento: " + lanzamiento

func _input(event):
	if event is InputEventKey and event.pressed:
		
		if event.keycode in teclas_numeros:
			if secuenciando:
				secuencia_ingresada += str(teclas_numeros.find(event.keycode))
			else:
				lanzamiento = str(teclas_numeros.find(event.keycode))
				$Display.text = "Lanzamiento: " + str(lanzamiento)
				
		if event.keycode == KEY_BRACKETLEFT:
			secuencia_ingresada += "["
		
		if event.keycode == KEY_BRACKETRIGHT:
			secuencia_ingresada += "]"
			
		if event.keycode == KEY_O:
			secuencia_ingresada += "("
		
		if event.keycode == KEY_P:
			secuencia_ingresada += ")"
			
		if event.keycode == KEY_X:
			secuencia_ingresada += "x"
			
		if event.keycode == KEY_SPACE:
			ingresar_secuencia()
	
func ingresar_secuencia():
	if len(secuencia_ingresada):
		secuencia = parsear_secuencia(secuencia_ingresada)
		secuencia_string = stringear_secuencia(secuencia)
		if "9" in secuencia_string:
			zoom.emit(9)
		elif "8" in secuencia_string:
			zoom.emit(8)
		else:
			zoom.emit(1)
		secuencia_ingresada = ""
	

func clear():
	secuencia = null
	secuencia_string = ""
	secuencia_ingresada = ""
	
func step():
	i_secuencia = i_secuencia % len(secuencia)
	var frame = secuencia[i_secuencia]
	i_secuencia += 1
	return frame
	
func next():
	if secuencia and secuenciando:
		return step()
	return null

func stringear_secuencia(secuencia):
	var stringueada = ""
	for frame in secuencia:
		
		if frame["tipo"] == "simple":
			stringueada += str(frame["lanz"])
			
		if frame["tipo"] == "multiplex":
			stringueada += "["
			stringueada += "".join(frame["lanz"])
			stringueada += "]"
			
		if frame["tipo"] == "sincro":
			stringueada += "("
			stringueada += stringear_secuencia([frame["lanz"][0]])
			stringueada += stringear_secuencia([frame["lanz"][1]])
			stringueada += ")"
	
	return stringueada

func parsear_secuencia(secuencia: String):
	
	var parseada = []
	var multiplex = null
	var sincro = null
	
	for i in range(len(secuencia)):
		var caracter = secuencia[i]
		var siguiente = secuencia[i + 1] if i < len(secuencia) - 1 else null
		
		if caracter == "[":
			multiplex = {"tipo": "multiplex", "lanz": []}
			
		if caracter == "]":
			if sincro:
				sincro["lanz"].push_back(multiplex)
			else:
				parseada.push_back(multiplex)
			multiplex = null
			
		if caracter == "(":
			sincro = {"tipo": "sincro", "lanz": []}
			
		if caracter == ")":
			parseada.push_back(sincro)
			sincro = null
			
		if caracter.is_valid_int():
			var lanz = caracter + "x" if siguiente == "x" else caracter
			if multiplex:
				multiplex["lanz"].push_back(lanz)
			elif sincro:
				sincro["lanz"].push_back({"tipo": "simple", "lanz": lanz})
			else:
				parseada.push_back({"tipo": "simple", "lanz": lanz})

	return parseada

