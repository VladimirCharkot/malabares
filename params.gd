extends Node

@export var g = 2
@export var dt = 350  # Periodo
@export var pa = 0.6  # Factor tiempo en el aire
var pm = 1 - pa
var dta = pa * dt 
var dtm = pm * dt

var labelFactor = false

var dx = 250

var calibracion = 'calculada'

func manual(is_manual: bool):
	if is_manual:
		calibracion = 'manual'
	else:
		calibracion = 'calculada'
