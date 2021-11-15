class_name LoopingAudioStreamPlayer
extends Node

export var intro_stream: AudioStream
export var loop_stream: AudioStream
export var outro_stream: AudioStream

export(float, -80, 24) var volume_db: float = 0
export(float, .1, 4) var pitch_scale: float = 1
var playing: bool = false setget set_playing
export var autoplay: bool = false
var stream_paused: bool = false setget , get_stream_paused
# sync_outro: if true, waits for the current loop iteration to finish
# before playing the outro plays.
export var sync_outro: bool = true
export(int, "Stereo", "Center", "Surround") var mix_target: int = 0
export var bus: String = "Master"

var _intro_player: AudioStreamPlayer
var _loop_player: AudioStreamPlayer
var _outro_player: AudioStreamPlayer

signal intro_finished()
signal finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create child nodes.
	_intro_player = AudioStreamPlayer.new()
	_loop_player = AudioStreamPlayer.new()
	_outro_player = AudioStreamPlayer.new()
	_intro_player.name = name + "_intro"
	_loop_player.name = name + "_loop"
	_outro_player.name = name + "_outro"
	_intro_player.stream = intro_stream
	_loop_player.stream = loop_stream
	_outro_player.stream = outro_stream
	_intro_player.mix_target = mix_target
	_loop_player.mix_target = mix_target
	_outro_player.mix_target = mix_target
	_intro_player.bus = bus
	_loop_player.bus = bus
	_outro_player.bus = bus
	
	_intro_player.connect("finished", _loop_player, "play")
	_outro_player.connect("finished", self, "_on_outro_finished")
	
	if autoplay:
		play()

func _on_outro_finished() -> void:
	emit_signal("finished")


# Plays the intro, and when this one finishes, plays the loop.
func play(from_position: float = 0.0) -> void:
	var intro_length = _intro_player.stream.get_length()
	var loop_length = _loop_player.stream.get_length()
	if from_position < intro_length:
		_intro_player.play(from_position)
	elif from_position < intro_length + loop_length:
		_loop_player.play(from_position)
	else:
		_outro_player.play(from_position)

# Causes the music to stop and the system to reset.
func stop() -> void:
	_intro_player.stop()
	_loop_player.stop()
	_outro_player.stop()
	emit_signal("finished")

# Plays the outro if exists. If not, it's equal to stop().
func end() -> void:
	if sync_outro:
		_loop_player.connect("finished", _loop_player, "stop")
		_loop_player.connect("finished", _outro_player, "play")
	else:
		_loop_player.stop()
		_outro_player.play()


# ---- Setters and getters

func set_playing(value: bool) -> void:
	pass # TODO: implement

func get_stream_paused() -> bool:
	return _intro_player.stream_paused and _loop_player.stream_paused and _outro_player.stream_paused
