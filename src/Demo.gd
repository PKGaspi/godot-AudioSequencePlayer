extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
export var _asp_path: NodePath
export var _data_play_from_path: NodePath
export var _data_seek_to_path: NodePath
export var _info_pos_path: NodePath
export var _info_current_path: NodePath
var _asp_node
var _data_play_from_node: LineEdit
var _data_seek_to_node: LineEdit
var _info_pos_node: Label
var _info_current_node: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_asp_node = get_node(_asp_path)
	_data_seek_to_node = get_node(_data_seek_to_path)
	_data_play_from_node = get_node(_data_play_from_path)
	_info_pos_node = get_node(_info_pos_path)
	_info_current_node = get_node(_info_current_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(_asp_node):
		_info_pos_node.text = str(_asp_node.get_playback_position())
		#_info_current_node.text = _asp_node.current_segment.name if _asp_node.current_segment else str(null)

func play_from() -> void:
	_asp_node.play(float(_data_play_from_node.text))
	
func seek_to() -> void:
	_asp_node.seek(float(_data_seek_to_node.text))

func paused(button_pressed: bool) -> void:
	_asp_node.stream_paused = button_pressed
