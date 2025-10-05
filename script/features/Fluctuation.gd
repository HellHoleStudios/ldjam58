extends StarFeature
class_name Fluctuation

var timer = 0
var interval = 1

func process(delta: float) -> void:
    timer += delta
    if timer >= interval:
        print("Fluctuation feature activated")
        star.split(star.mass * 0.3)
        timer -= interval
