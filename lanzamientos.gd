extends Node


func viy(t):
	return -0.5 * Params.g * t
	
# dx = vix * t
func vix(t, dx):
	return  dx * (1000 / float(t))

func vi(t, dx):
	return Vector2(vix(t,dx), viy(t))
	
func lanzamiento(n, dx):
	n = int(n)
	var t = Params.dta + (n-1) * Params.dt
	print("Calculando con n=", n, " y dx=", dx, " :: t=", t)
	print(vi(t, dx))
	return vi(t, dx)

var siteswap = {
	"0": Vector2.ZERO,
	"1": Vector2(900, -170),
	"2": Vector2(-65, -600),
	"3": Vector2(270, -900),
	"4": Vector2(-60, -1150),
	"5": Vector2(200, -1450),
	"6": Vector2(-50, -1600),
	"7": Vector2(110, -1950),
	"8": Vector2(-40, -2400),
	"9": Vector2(80, -3000),
	
	"1x": Vector2(-240, -350),
	"2x": Vector2(580, -400),
	"3x": Vector2(-70, -900),
	"4x": Vector2(200, -1150),
	"5x": Vector2(-30, -1450),
	"6x": Vector2(130, -1600),
	"7x": Vector2(-25, -1950),
	"8x": Vector2(90, -2300),
	"9x": Vector2(-15, -3000),
}

# Traduce un lanzamiento o lista de lanzamientos a vectores
func traducir(lanz):
	if Params.calibracion == "manual": 
		if typeof(lanz) == typeof([]):
			return lanz.map(func (l): return siteswap[l])
		else:
			return siteswap[lanz]
	else:
		if typeof(lanz) == typeof([]):
			return lanz.map(func (l): return lanzamiento(l, Params.dx))
		else:
			return lanzamiento(lanz, Params.dx)
	


