extends Node

var reproduciendo = true


func activar():
	$Audio.stream = $Player/Audio/Tracks.tracks[0]
	#$Audio.play()
	$Next.visible = true
	$PlayPause.visible = true


func _on_play_pause_pressed():
	$Audio.stream_paused = not($Audio.stream_paused)
	if $Audio.stream_paused:
		$PlayPause.texture_normal = $PlayPause.textura_play
	else:
		$PlayPause.texture_normal = $PlayPause.textura_pause


func _on_next_pressed():
	$Audio.n_track += 1
	$Audio.stream = $Audio/Tracks.tracks[$Audio.n_track]
	$Audio.play()
