class_name StarFeature

var star: Star
var level: int

static func get_feature_name() -> String:
	return "MISSINGNO"
static func get_feature_desc() -> String:
	return "MISSINGDESC"
	
func init(_star: Star, _level: int) -> void:
	star = _star
	level = _level
	_star.features.append(self)

func _init(_star: Star, _level: int):
	init(_star, _level)

# virtual
func process(delta: float) -> void:
	pass

func draw() -> void:
	pass

func merge(other: StarFeature) -> void:
	level += other.level

func crash(other: Star) -> bool:
	return false

static func mergeable() -> bool:
	return true

static func generate_weight(stars: Array[Node], player: PlayerStar, star: Star) -> float:
	return 0
