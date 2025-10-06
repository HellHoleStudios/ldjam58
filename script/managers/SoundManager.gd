extends Node

class_name SoundManager

# 单例模式
static var instance: SoundManager

var main_volume: float = 1.0

func _ready() -> void:
	instance = self
	play_music_loop("res://sound/midnight_drive.ogg")

# 播放音效
func play_sound(sound_path: String, volume: float = 1.0) -> void:
	volume = clamp(volume, 0.0, 1.0)
	volume *= main_volume
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_path)
	sound.volume_db = 20 * log(volume) / log(10)
	add_child(sound)
	sound.play()
	await sound.finished
	sound.queue_free()

# 循环播放音乐
func play_music_loop(sound_path: String):
	var music = AudioStreamPlayer.new()
	var stream = load(sound_path)
	if stream is AudioStream:
		stream.loop = true
	music.stream = stream
	music.volume_db = 20 * log(main_volume) / log(10)
	add_child(music)
	music.play()