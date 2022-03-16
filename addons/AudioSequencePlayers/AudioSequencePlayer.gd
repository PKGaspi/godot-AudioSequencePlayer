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

var _current_segment_index: int = 0
var _current_segment: Resource setget , get_current_segment

var _players: Array
var _current_player: AudioStreamPlayer setget , get_current_player

signal segment_finished(segment)
signal finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create child nodes.
	_players = []
	var i = 0
	for segment in segments:
		assert(segment is AudioSegment)
		var player = AudioStreamPlayer.new()
		player.name = name + "_" + segment.name
		player.stream = segment.stream
		player.mix_target = mix_target
		player.bus = bus
		player.connect("finished", self, "_on_segment_finished")
		add_child(player)
		_players.append(player)
		i += 1
	
	if autoplay:
		play()

func _on_segment_finished() -> void:
	emit_signal("segment_finished", self._current_segment)
	if not playing:
		return
	if looping:
		self._current_player.play()
		return
	_current_segment_index += 1
	if _current_segment_index < len(_players):
		# Play next segment.
		self._current_player.play()
		looping = self._current_segment.loop
	else:
		_current_segment_index -= 1
		playing = false

# Plays the intro, and when this one finishes, plays the loop.
func play(from_position: float = 0.0) -> void:
	if playing:
		# Stop this segment and wait for it to emit signal finished.
		var previous_player = self._current_player
		previous_player.stream_paused = false
		stop()
		yield(previous_player, "finished")
	var segment_position = seek(from_position)
	self._current_player.stream_paused = stream_paused
	self._current_player.play(segment_position)
	playing = true

func seek(to_position: float) -> float:
	if playing:
		var previous_player = self._current_player
		previous_player.stream_paused = false
		stop()
		yield(previous_player, "finished")
		playing = true
	for i in range(len(segments)):
		if to_position < segments[i].get_length():
			# This is the segment to play.
			_current_segment_index = i
			self._current_player.seek(to_position)
			self._current_player.playing = playing
			self._current_player.stream_paused = stream_paused
			looping = self._current_segment.loop
			break
		to_position -= segments[i].get_length()
	return to_position

# Causes the music to stop and the system to reset.
func stop() -> void:
	if not playing:
		return
	playing = false
	self._current_player.stop()
	emit_signal("finished")

# Play next segment to the current one.
func next() -> void:
	if not is_instance_valid(self._current_segment):
		return
	if self._current_segment.sync_ending:
		next_sync()
	else:
		next_async()

func next_async() -> void:
	# Stopping will emit this player's finished
	# signal and play the next segment.
	looping = false
	self._current_player.stop()


func next_sync() -> void:
	looping = false


# ---- Setters and getters

func set_playing(value: bool) -> void:
	playing = value
	self._current_player.playing = value

func set_stream_paused(value: bool) -> void:
	stream_paused = value
	self._current_player.stream_paused = value

func get_stream_paused() -> bool:
	return self._current_player.stream_paused

func get_playback_position() -> float:
	if not is_instance_valid(self._current_segment):
		return .0
	var acc: float = .0
	for i in range(_current_segment_index):
		acc += segments[i].get_length()
	acc += self._current_player.get_playback_position()
	return acc
	
func get_current_segment() -> Resource:
	if not _current_segment_index < len(segments):
		return null
	return segments[_current_segment_index]

func get_current_player() -> AudioStreamPlayer:
	if not _current_segment_index < len(_players):
		return null
	return _players[_current_segment_index]
	
