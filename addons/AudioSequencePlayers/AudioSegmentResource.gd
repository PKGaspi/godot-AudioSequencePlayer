extends Resource
class_name AudioSegment, "icons/AudioSegmentResource.svg"

export var name: String
export var stream: AudioStream
export var loop: bool
export var sync_ending: bool

func get_length() -> float:
	return stream.get_length()
