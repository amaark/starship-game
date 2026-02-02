extends RigidBody2D

@onready var dodge_cooldown: Timer = $DodgeCooldown

enum STATE {
	NORMAL,
	DODGE,
}
const THRUST := Vector2(0, -1500)
const TORQUE := 2500
const DODGE_THRUST := Vector2(1500, 0)
var active_state := STATE.NORMAL
var dodge_direction := Vector2(0, 0)


func _integrate_forces(phys_state: PhysicsDirectBodyState2D) -> void:
	process_state(phys_state)


func process_state(phys_state: PhysicsDirectBodyState2D) -> void:
	match active_state:
		STATE.NORMAL:
			handle_movement(phys_state)
		STATE.DODGE:
			switch_state(STATE.NORMAL)
			handle_movement(phys_state)


func handle_movement(phys_state: PhysicsDirectBodyState2D) -> void:
	var thrust_direction = 0
	var rotation_direction = 0

	if Input.is_action_pressed("forward_thrust"):
		thrust_direction += 1
	if Input.is_action_pressed("backward_thrust"):
		thrust_direction -= 1
	if Input.is_action_pressed("turn_right"):
		rotation_direction += 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction -= 1

	phys_state.apply_force(thrust_direction * THRUST.rotated(rotation))
	phys_state.apply_torque(rotation_direction * TORQUE)

	if Input.is_action_just_pressed("dodge_right") and dodge_cooldown.time_left == 0:
		switch_state(STATE.DODGE)
		phys_state.apply_central_impulse(DODGE_THRUST.rotated(rotation))
	elif Input.is_action_just_pressed("dodge_left") and dodge_cooldown.time_left == 0:
		switch_state(STATE.DODGE)
		phys_state.apply_central_impulse(-DODGE_THRUST.rotated(rotation))


func switch_state(new_state: STATE) -> void:
	active_state = new_state

	match active_state:
		STATE.DODGE:
			dodge_cooldown.start()
