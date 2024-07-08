extends Control


var dx_mano = 80
var dt_mano = 0.3

# Si la anterior fue sincro hay que esperar un tiempo más
var did_sincro = false

	
func _input(event):
	#if event is InputEventMouseMotion:
		#pass
		#print(event)
	if event is InputEventKey and event.pressed:
				
		if event.keycode == KEY_C: 
			$Secuencias.clear()
			
		if event.keycode == KEY_A:
			$Malabarista.swap()
			$Malabarista.crear_pelotas(1)
			
		if event.keycode == KEY_LEFT:
			var l = $Lanzamientos.lanzamiento(int($Secuencias.lanzamiento), 240)
			await $Malabarista.simple($Malabarista/ManoIzq, l)
			$Malabarista.swap()
		
		if event.keycode == KEY_RIGHT:
			var l = $Lanzamientos.lanzamiento(int($Secuencias.lanzamiento), 240)
			await $Malabarista.simple($Malabarista/ManoDer, l)
			$Malabarista.swap()


func _on_base_timeout():
	if did_sincro:	# Esperar un step extra
		did_sincro = false
		return
	if $Secuencias.secuenciando and $Secuencias.secuencia:
		var frame = $Secuencias.step()
		delegar(frame)
		$Malabarista.swap()


func _on_secuencias_zoom(level):
	zoom(level)
	
func zoom(n):
	var t = get_tree().create_tween()
	if n == 9:
		t.tween_property($Camera2D, "zoom", Vector2(0.55,0.55), 1)
		t.tween_property($Camera2D, "position", Vector2(576,435), 1)
	if n == 8:
		t.tween_property($Camera2D, "zoom", Vector2(0.8,0.8), 1)
		t.tween_property($Camera2D, "position", Vector2(576,665), 1)
	if n == 1:
		t.tween_property($Camera2D, "position", Vector2(576,725), 1)
		t.tween_property($Camera2D, "zoom", Vector2(1,1), 1)



# Recibe un frame y delega la acción al malabarista
func delegar(frame):
	print(frame)
	
	if frame["tipo"] == "simple":
		var l = $Lanzamientos.traducir(frame["lanz"])
		#var l = $Lanzamientos.lanzamiento(int(frame["lanz"]), 260)
		await $Malabarista.simple($Malabarista.mano_activa, l)

	if frame["tipo"] == "multiplex":
		var ls = frame["lanz"].map(func (l): return $Lanzamientos.traducir(l))
		await $Malabarista.multiplex($Malabarista.mano_activa, ls)

	if frame["tipo"] == "sincro":
		var m_activa = frame["lanz"][0]
		var m_inactiva = frame["lanz"][1]
		did_sincro = true
		await $Malabarista.sincro(
			$Lanzamientos.traducir(m_activa["lanz"]), 
			$Lanzamientos.traducir(m_inactiva["lanz"])
		)




func _on_boton_pressed():
	bajar_portada_y_arrancar_jueguito()
	
func bajar_portada_y_arrancar_jueguito():
	var t = create_tween()
	t.tween_property($Portada/Boton, "modulate", Color.TRANSPARENT, 1)
	t.tween_property($Portada/Titulo, "modulate", Color.TRANSPARENT, 1)
	t.tween_property($Malabarista, "modulate", Color.WHITE, 1)
	t.tween_callback(
		func():
			$Portada.visible = false
			$Player.activar()
			$Secuencias.visible = true
			$Base.start()
	)


func _on_modo_toggled(toggled_on):
	$Secuencias.secuenciando = toggled_on
	if toggled_on:
		$Base.start()
	else:
		$Base.stop()

