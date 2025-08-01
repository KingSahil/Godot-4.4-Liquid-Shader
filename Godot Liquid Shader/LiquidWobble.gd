# ANCHOR: all
@tool
extends MeshInstance3D

# How high is the wobble
@export var max_wobble := 0.1
# How much do we need to move to reach the maximum wobble intensity, in a second
@export var movement_to_max_wobble := 0.3
# How much do we need to be rotated to reach maximum wobble intensity, in a second
@export var rotation_to_max_wobble := PI / 2.0
# How long it takes for the liquid to become still again
@export var wobble_damping := 1.0
# How fast will the liquid wobble
@export var wobble_speed := 2.0

var _accumulated_time := 0.0
# ANCHOR: intensity
var _wobble_intensity := 0.0
# END: intensity
# ANCHOR: movement
@onready var _prev_pos := global_transform.origin
@onready var _prev_rot := rotation


func _process(delta: float) -> void:
	# Calculate how much we moved/rotated
	var current_movement_len := (global_transform.origin - _prev_pos).length()
	var current_rotation_len := (rotation - _prev_rot).length()
	_prev_pos = global_transform.origin
	_prev_rot = rotation
# END: movement
	# ANCHOR: decay
	# The decay here is multiplied by the wobble intensity so that the more the fluid is
	# getting still, the longer it will take to be completely still
	_wobble_intensity -= delta / wobble_damping * _wobble_intensity
	# END: decay
	# ANCHOR: add_wobble
	_wobble_intensity += current_movement_len / movement_to_max_wobble
	_wobble_intensity += current_rotation_len / rotation_to_max_wobble
	# END: add_wobble
	# ANCHOR: clamp
	_wobble_intensity = clamp(_wobble_intensity, 0.0, 1.0)
	# END: clamp
	# ANCHOR: time
	# We make the accumulated time go slower the slower the wobble is
	# this will make the liquid rotate slower when the effect is decaying
	_accumulated_time += delta * _wobble_intensity * wobble_speed
	# END: time
	# ANCHOR: shader_param
	material_override.set_shader_parameter(
		"wobble",
		(
			Vector2.RIGHT.rotated(_accumulated_time * TAU)
			* max_wobble
			* _wobble_intensity
		)
	)
	# END: shader_param
# END: all
