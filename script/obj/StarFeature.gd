class_name StarFeature

var star: Star
var level: int

func init(_star: Star, _level: int) -> void:
    star = _star
    level = _level
    star.features.append(self)

func _init(_star: Star, _level: int):
    init(_star, _level)

# virtual
func process(delta: float) -> void:
    pass

func draw() -> void:
    pass

func merge(other: StarFeature) -> void:
    level += other.level

static func generate_weight(stars: Array[Node], player: PlayerStar) -> float:
    return 100