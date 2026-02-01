extends RigidBody2D

enum state {
	NORMAL,
	DASH
}

const THRUST := Vector2(0, -250)
const TORQUE := 50

var active_state := state.NORMAL
var dash_direction := Vector2(0, 0)

func _integrate_forces(phys_state: PhysicsDirectBodyState2D) -> void:
	handle_movement(phys_state)

func handle_movement(phys_state: PhysicsDirectBodyState2D):
	if Input.is_action_pressed("forward_thrust"):
		phys_state.apply_force(THRUST.rotated(rotation))
	elif Input.is_action_pressed("backward_thrust"):
		phys_state.apply_force(-THRUST.rotated(rotation))
	else:
		phys_state.apply_force(Vector2())
		
	var rotation_direction = 0
	
	if Input.is_action_pressed("turn_right"):
		rotation_direction += 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction -= 1
	
	phys_state.apply_torque(rotation_direction * TORQUE)
