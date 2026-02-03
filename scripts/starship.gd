extends RigidBody2D

@onready var dodge_cooldown: Timer = $DodgeCooldown
@onready var boost_cooldown: Timer = $BoostCooldown

enum STATE {
	NORMAL,
	DODGE,
	BOOST,
}
const THRUST := Vector2(0, -3000)
const DODGE_THRUST := Vector2(2000, 0)
const BOOST_THRUST := Vector2(0, -4000)
const TORQUE := 2000
var active_state := STATE.NORMAL
var phys_state: PhysicsDirectBodyState2D
var is_boosting := false


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	phys_state = state
	match active_state:
		STATE.NORMAL:
			handle_movement()
			handle_dodge()
			if Input.is_action_just_pressed("boost") and boost_cooldown.time_left == 0:
				phys_state.apply_central_impulse(BOOST_THRUST.rotated(rotation))
				switch_state(STATE.BOOST)
		STATE.BOOST:
			if Input.is_action_just_released("boost"):
				switch_state(STATE.NORMAL)
			else:
				handle_boost()
				handle_dodge()
		STATE.DODGE:
			if is_boosting:
				switch_state(STATE.BOOST)
			else:
				switch_state(STATE.NORMAL)


func switch_state(new_state: STATE) -> void:
	var previous_state := active_state
	active_state = new_state

	match active_state:
		STATE.NORMAL:
			is_boosting = false
			boost_cooldown.start()
		STATE.DODGE:
			dodge_cooldown.start()
		STATE.BOOST:
			is_boosting = true


func handle_movement() -> void:
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


func handle_boost() -> void:
	var rotation_direction = 0

	if Input.is_action_pressed("turn_right"):
		rotation_direction += 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction -= 1

	phys_state.apply_force(BOOST_THRUST.rotated(rotation))
	phys_state.apply_torque(rotation_direction * TORQUE)


func handle_dodge() -> void:
	if dodge_cooldown.time_left > 0:
		return
	if Input.is_action_just_pressed("dodge_right"):
		switch_state(STATE.DODGE)
		phys_state.apply_central_impulse(DODGE_THRUST.rotated(rotation))
	elif Input.is_action_just_pressed("dodge_left"):
		switch_state(STATE.DODGE)
		phys_state.apply_central_impulse(-DODGE_THRUST.rotated(rotation))
