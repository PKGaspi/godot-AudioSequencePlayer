class_name LoopingAudioStreamPlayer
extends Node


export var intro: AudioStream
export var stream: AudioStream
export var outro: AudioStream

export(float, -80, 24) var volume_db: float = 0
export(float, .1, 4) var pitch_scale: float = 1
export var playing: bool = false
export var autoplay: bool = false
export var stream_paused: bool = false
export var sync_outro: bool = true
export(int, "Stereo", "Center", "Surround") var mix_target: int = 0
export var bus: String = "Master"

signal intro_finished()
signal finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Plays the intro, and when this one finished, the looping will begin.
func play(from_position: float = 0.0) -> void:
	pass

# Causes the music to stop and the system to reset.
func stop() -> void:
	pass

# Plays the outro (if exists).
func end() -> void:
	pass
