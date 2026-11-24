extends CharacterBody3D

@export var speed: float = 12.0
@export var jump_force: float = 10.0
@export var gravity: float = 30.0

var money: int = 0
var input_dir: Vector2 = Vector2.ZERO
var current_vehicle: VehicleBody3D = null

@onready var mesh = $MeshInstance3D
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D

func _physics_process(delta):
    if current_vehicle:
        # Kontrol Mobil
        current_vehicle.engine_force = -input_dir.y * 800.0
        current_vehicle.steering = -input_dir.x * 0.4
        global_position = current_vehicle.global_position + Vector3(0, 2.5, 0)
        mesh.visible = false
        return

    mesh.visible = true

    if not is_on_floor():
        velocity.y -= gravity * delta

    # Pergerakan relatif terhadap kamera
    var direction = (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    direction.y = 0
    direction = direction.normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        var target_angle = atan2(-direction.x, -direction.z)
        mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle, 0.2)
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()

func jump():
    if is_on_floor() and not current_vehicle:
        velocity.y = jump_force

func shoot():
    if current_vehicle: return
    var space_state = get_world_3d().direct_space_state
    var screen_center = get_viewport().get_visible_rect().size / 2
    var origin = camera.project_ray_origin(screen_center)
    var end = origin + camera.project_ray_normal(screen_center) * 150
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    query.exclude = [self.get_rid()]
    
    var result = space_state.intersect_ray(query)
    if result and result.collider.has_method("take_damage"):
        result.collider.take_damage(50)
        if get_node_or_null("../../Main"):
            get_node("../../Main").add_wanted_level()

func interact():
    if current_vehicle:
        # Keluar Mobil
        current_vehicle.exit_vehicle(self)
        current_vehicle = null
    else:
        # Cari Mobil Terdekat
        var vehicles = get_tree().get_nodes_in_group("vehicles")
        for v in vehicles:
            if global_position.distance_to(v.global_position) < 6.0:
                current_vehicle = v
                current_vehicle.enter_vehicle(self)
                break
