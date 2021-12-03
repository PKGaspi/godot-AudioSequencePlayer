# Audio Sequence Players

A small tool to help create sequences of audio stream and play them in order.
Facilitates the creation of flexible looping sounds and music.

## Usage

For a better understanding of the tool, please consider taking a look at the
[demo](https://github.com/PKGaspi/godot-AudioSequencePlayer/tree/demo).

### AudioSegmentResource

A Resource Class to manage your segments. A segment is basically an audio stream
with some options.

#### Properties

- `name: String`: The name of this segment. Can be empty, null or not unique.
- `stream: AudioStream`: The audio stream of this segment.
- `loop: bool`: Wether to loop this segment when finishes or not.
- `sync_ending`: If true, waits for this segment to finish before playing
  the next one when calling `ÀudioSequencePlayer.next()`.

#### Methods

- `float get_length()` Returns the length of `stream`.

### AudioSequencePlayer(/2D/3D)

A Class to play a sequence of `AudioSegmentResource`. There are three variants,
depending if you want to play global, 2D or 3D audio.

It's interface is pretty much the same as the included
`AudioStreamPlayer(/2D/3D)`, with the inclusion of a few things. Properties
that lack a description work as they would work on a
`AudioStreamPlayer(/2D/3D)`.

#### Signals

- `segment_finished(segment: AudioSegmentResource)`: Emitted when `segment` has
  finished playing. If `segment` is a looping segment, it won't be emitted until
  the loop is cut with `next()`.
- `finished`

#### Properties

- `segments: Array(AudioSegmentResource)`: An ordered list of the segments to
  play. Segments can be included multiple times in the array.
- `volume_db: float`
- `pitch_scale: float`
- `playing: bool`
- `autoplay: bool`
- `stream_paused: bool`
- `looping: bool`: Wether or not `current_segment` is looping. If it is, it
  won't change to the next segment until `next()` is called.
- `mix_target: Stereo, Center, Surround`: Only for AudioSequencePlayer (not 2D
  or 3D).
- `bus: String`: I didn't find a way to list the available busses as in
  `AudioStreamPlayer`. You have to manually type the bus name.
- `current_segment_index: int`: The index of the current segment playing in
  `segments`.
- `current_segment: AudioSegmentResource`: The currently playing segment.

#### Methods

- `float get_playback_position()`: Returns the position of the sequence in seconds.
- ~~`AudioStreamPlayback get_stream_playback()`~~: Not implemented.
- `void play(from_position: float = 0.0)`: Plays the audio sequence from the
  given position in seconds.
- `void seek(float to_position)`: Sets the position from which audio will be
  played, in seconds.
- `void stop()`: Stops the audio.
- `void next()`: Plays the next segment. If `current_segment` has `sync_ending`
  set to `true`, `current_segment` will finish playing before moving to the next
  one. Otherwise, it will be stopped immediately and the next one will begin. It
  will be called automatically on segments with `loop` set to false
- `void next_async()`: Forces `current_segment` to stop playing and the next one
  to start. Same as calling `next()` on a segment with `sync_ending` set to
  `false`.
- `void next_sync()`: Allows `current_segment` to finish and the plays the next
  segment. Same as calling `next()` on a segment with `sync_ending` set to
  `true`.

---

## About me

- Web: [gaspi.games](http://gaspi.games/)
- Twitter: [@_Gaspi](https://twitter.com/@_Gaspi)
- Godot Asset Library: [Gaspi](https://godotengine.org/asset-library/asset?user=Gaspi)