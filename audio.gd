extends AudioStreamPlayer


var n_track = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	stream = $Tracks.track_portada
	#play()


func _on_finished():
	n_track += 1
	stream = $Tracks.tracks[n_track]
	play()
