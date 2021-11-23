extends Resource
class_name AudioSegment, "icons/AudioSegmentResource.svg"

export var name: String
export var stream: AudioStream
export var loop: bool
# sync_ending: if true, waits for this segment to finish
# before playing the next one.
export var sync_ending: bool

func get_length() -> float:
	return stream.get_length()
