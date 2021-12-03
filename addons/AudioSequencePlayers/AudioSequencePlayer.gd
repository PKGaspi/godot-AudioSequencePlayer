extends Node
class_name AudioSequencePlayer, "icons/AudioSequencePlayer.svg"

export(Array, Resource) var segments: Array

export(float, -80, 24) var volume_db: float = 0
export(float, .1, 4) var pitch_scale: float = 1
var playing: bool = false
export var autoplay: bool = false
var stream_paused: bool = false setget set_stream_paused
var looping: bool = false
export(int, "Stereo", "Center", "Surround") var mix_target: int = 0
export var bus: String = "Master"

var current_segment_index: int = -1
var current_segment: Resource

var _players: Dictionary = {}

signal segment_finished(segment)
signal finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create child nodes.
	for segment in segments:
		assert(segment is AudioSegment)
		if segment in _players.keys():
			segment = segment.duplicate()
		var player = AudioStreamPlayer.new()
		player.name = name + "_" + segment.name
		player.stream = segment.stream
		player.mix_target = mix_target
		player.bus = bus
		player.connect("finished", self, "_on_segment_finished")
		add_child(player)
		_players[segment] = player
	
	if autoplay:
		play()

func _on_segment_finished() -> void:
	if not playing:
		return
	if looping:
		_players[current_segment].play()
		return
	emit_signal("segment_finished", current_segment)
	next_async()


# Plays the intro, and when this one finishes, plays the loop.
func play(from_position: float = 0.0) -> void:
	var acc = .0
	current_segment_index = 0
	for segment in segments:
		var stream_len = segment.get_length()
		if from_position < acc + stream_len:
			# This is the segment to play.
			current_segment = segment
			_players[current_segment].play(from_position - acc)
			looping = current_segment.loop
			playing = true
			break
		acc += stream_len
		

func seek(to_position: float) -> void:
	if not playing:
		return
	current_segment_index = 0
	for segment in segments:
		var stream_len = segment.set_length()
		if to_position < stream_len:
			if to_position < 0:
				stop()
				return
			# This is the segment to seek to.
			_players[current_segment].stop()
			current_segment = segment
			_players[current_segment].play(to_position)
			looping = current_segment.loop
			break
		else:
			to_position -= stream_len

# Causes the music to stop and the system to reset.
func stop() -> void:
	playing = false
	_players[current_segment].stop()
	emit_signal("finished")
	current_segment_index = -1
	current_segment = null

# Play next segment to the current one.
func next() -> void:
	if not is_instance_valid(current_segment):
		return
	if current_segment.sync_ending:
		next_sync()
	else:
		# Stopping will emit this player's finished
		# signal and play the next segment.
		_players[current_segment].stop()
		looping = false

func next_async() -> void:
	current_segment_index += 1
	if current_segment_index < len(segments):
		# Play next segment.
		_players[current_segment].stop()
		current_segment = segments[current_segment_index]
		_players[current_segment].play()
		looping = current_segment.loop
	else:
		# The sequence has finished.
		stop()

func next_sync() -> void:
	looping = false


# ---- Setters and getters

func set_playing(value: bool) -> void:
	playing = value
	_players[current_segment].playing = value

func set_stream_paused(value: bool) -> void:
	stream_paused = value
	_players[current_segment].stream_paused = value

func get_stream_paused() -> bool:
	return _players[current_segment].stream_paused

func get_playback_position() -> float:
	var acc: float = .0
	for i in range(current_segment_index):
		acc += segments[i].get_length()
	acc += current_segment.get_length()
	return acc
	
