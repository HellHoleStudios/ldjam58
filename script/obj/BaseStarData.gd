## The base class for all stars
class_name BaseStarData

var mass: float
var sprite: Sprite2D
var collision_shape: CollisionShape2D
var rigidbody: RigidBody2D

func _init(_mass: float = 1.0, _sprite: Sprite2D = null, _collision_shape: CollisionShape2D = null, _rigidbody: RigidBody2D = null):
    mass = _mass
    sprite = _sprite
    collision_shape = _collision_shape
    rigidbody = _rigidbody
    if sprite and collision_shape:
        update_visual()

func get_mass() -> float:
    return mass

func set_mass(_mass: float):
    mass = _mass
    update_visual()

func get_radius() -> float:
    return mass

func update_visual():
    var radius = get_radius()
    if sprite:
        sprite.scale = Vector2(1, 1) * radius / 32
    if collision_shape and collision_shape.shape is CircleShape2D:
        collision_shape.shape.radius = radius

func set_sprite(_sprite: Sprite2D):
    sprite = _sprite
    update_visual()

func set_collision_shape(_collision_shape: CollisionShape2D):
    collision_shape = _collision_shape
    update_visual()

func set_rigidbody(_rigidbody: RigidBody2D):
    rigidbody = _rigidbody

func get_sprite() -> Sprite2D:
    return sprite

func get_collision_shape() -> CollisionShape2D:
    return collision_shape

func get_rigidbody() -> RigidBody2D:
    return rigidbody

func apply_force(force: Vector2):
    if rigidbody:
        rigidbody.apply_central_impulse(force)