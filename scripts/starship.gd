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
var dodge_direction := Vector2(0, 0)


func _integrate_forces(phys_state: PhysicsDirectBodyState2D) -> void:
	match active_state:
		STATE.NORMAL:
			handle_movement(phys_state)
			handle_dodge(phys_state)
			if Input.is_action_pressed("boost") and boost_cooldown.time_left == 0:
				phys_state.apply_central_impulse(BOOST_THRUST.rotated(rotation))
				switch_state(STATE.BOOST)
		STATE.BOOST:
			if Input.is_action_just_released("boost"):
				switch_state(STATE.NORMAL)
			else:
				handle_boost(phys_state)
				handle_dodge(phys_state)
		STATE.DODGE:
			switch_state(STATE.NORMAL)
			handle_movement(phys_state)


func switch_state(new_state: STATE) -> void:
	active_state = new_state

	match active_state:
		STATE.DODGE:
			dodge_cooldown.start()
		STATE.BOOST:
			boost_cooldown.start()


func handle_movement(phys_state: PhysicsDirectBodyState2D, thrust: Vector2 = THRUST) -> void:
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

	phys_state.apply_force(thrust_direction * thrust.rotated(rotation))
	phys_state.apply_torque(rotation_direction * TORQUE)


func handle_boost(phys_state: PhysicsDirectBodyState2D) -> void:
	var rotation_direction = 0

	if Input.is_action_pressed("turn_right"):
		rotation_direction += 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction -= 1

	phys_state.apply_force(BOOST_THRUST.rotated(rotation))
	phys_state.apply_torque(rotation_direction * TORQUE)


func handle_dodge(phys_state: PhysicsDirectBodyState2D) -> void:
	if dodge_cooldown.time_left > 0:
		return
	if Input.is_action_just_pressed("dodge_right"):
		switch_state(STATE.DODGE)
		phys_state.apply_central_impulse(DODGE_THRUST.rotated(rotation))
	elif Input.is_action_just_pressed("dodge_left"):
		switch_state(STATE.DODGE)
		phys_state.apply_central_impulse(-DODGE_THRUST.rotated(rotation))
