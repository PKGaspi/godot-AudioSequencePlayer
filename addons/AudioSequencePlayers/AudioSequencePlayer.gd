extends Node
class_name AudioSequencePlayer, "icons/AudioSequencePlayer.svg"

export(Array, Resource) var segments: Array

export(float, -80, 24) var volume_db: float = 0
export(float, .1, 4) var pitch_scale: float = 1
var playing: bool = false
export var autoplay: bool = false
var stream_paused: bool = false setget set_stream_paused
var looping: bool = false
# sync_outro: if true, waits for the current loop iteration to finish
# before playing the outro plays.
export var sync_outro: bool = true
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
		var player = AudioStreamPlayer.new()
		player.name = name + "_" + segment.name
		player.stream = segment.stream
		player.mix_target = mix_target
		player.bus = bus
		player.connect("finished", self, "_on_segment_finished")
		add_child(player)
		_players[segment.name] = player
	
	if autoplay:
		play()

func _on_segment_finished() -> void:
	if not playing:
		return
	if looping:
		_players[current_segment.name].play()
		return
	emit_signal("segment_finished", current_segment)
	next_async()


# Plays the intro, and when this one finishes, plays the loop.
func play(from_position: float = 0.0) -> void:
	var acc = .0
	current_segment_index = 0
	for segment in segments:
		var stream_len = segment.stream.get_length()
		if from_position < acc + stream_len:
			# This is the segment to play.
			current_segment = segment
			_players[current_segment.name].play(from_position - acc)
			looping = current_segment.loop
			playing = true
			break
		acc += stream_len
		

# Causes the music to stop and the system to reset.
func stop() -> void:
	playing = false
	_players[current_segment.name].stop()
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
		_players[current_segment.name].stop()
		looping = false

func next_async() -> void:
	current_segment_index += 1
	if current_segment_index < len(segments):
		# Play next segment.
		_players[current_segment.name].stop()
		current_segment = segments[current_segment_index]
		_players[current_segment.name].play()
		looping = current_segment.loop
	else:
		# The sequence has finished.
		stop()

func next_sync() -> void:
	looping = false


# ---- Setters and getters

func set_playing(value: bool) -> void:
	playing = value
	_players[current_segment.name].playing = value

func set_stream_paused(value: bool) -> void:
	stream_paused = value
	_players[current_segment.name].stream_paused = value

func get_stream_paused() -> bool:
	return _players[current_segment.name].stream_paused
