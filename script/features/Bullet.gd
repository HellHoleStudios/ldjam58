extends StarFeature
class_name Bullet

var cooldown = 5.0
var timer = 0.0

func mergeable() -> bool:
    return false

func process(delta: float) -> void:
    timer -= delta
    if timer < 0:
        timer = 0

func crash(other: Star) -> bool:
    print("Bullet crash detected")
    if timer > 0:
        return false
    if other.mass < star.mass:
        return false
    else:
        timer = cooldown
        var damage = star.mass
        other.merge(star)
        for i in range(3):
            other.split(min(other.mass * 0.5, damage * 0.8))
        
        return true
