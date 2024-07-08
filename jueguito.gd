extends Control

var dx_mano = 80
var dt_mano = 0.3

func _input(event):
	
	if event is InputEventKey and event.pressed:
		
		if event.keycode == KEY_C: 
			$Secuencia.clear()
			
		if event.keycode == KEY_A:
			$Malabarista.swap()
			$Malabarista.crear_pelotas(1)


func secuenciar():
	while $Secuencia.secuenciando:
		var comando = $Secuencia.next()
		$Malabarista.encolar(comando)
		await $Malabarista.comando_ejecutado


func _on_secuencias_zoom(level):
	$Camara.focus(level)


func iniciar():
	$Player.activar()
	$Malabarista.aparecer()
	$Secuencia.visible = true


func _on_boton_pressed():
	await $Portada.bajar()
	iniciar()


func _on_modo_toggled(toggled_on):
	$Secuencia.secuenciando = toggled_on
	$Malabarista.set_secuenciando(toggled_on)
	secuenciar()
