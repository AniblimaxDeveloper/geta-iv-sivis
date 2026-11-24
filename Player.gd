extends CharacterBody3D

@export var speed: float = 15.0
@export var jump_force: float = 10.0
@export var gravity: float = 30.0

var money: int = 0
var health: float = 100.0
var ammo: int = 150
var weapon_type: int = 1 # 1 = Pistol, 2 = SMG
var input_dir: Vector2 = Vector2.ZERO
var current_vehicle: VehicleBody3D = null
var walk_time: float = 0.0

@onready var mesh_root = $MeshRoot
@onready var left_leg = $MeshRoot/LeftLeg
@onready var right_leg = $MeshRoot/RightLeg
@onready var left_arm = $MeshRoot/LeftArm
@onready var right_arm = $MeshRoot/RightArm
@onready var weapon = $MeshRoot/Weapon
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var vignette = get_node_or_null("../../UI/DamageVignette")

func _physics_process(delta):
    if vignette:
        if health < 40:
            vignette.color.a = lerp(vignette.color.a, 0.5, 0.1)
        else:
            vignette.color.a = lerp(vignette.color.a, 0.0, 0.1)

    if current_vehicle:
        if input_dir.y > 0:
            current_vehicle.brake = input_dir.y * 15.0
            current_vehicle.engine_force = 0
        else:
            current_vehicle.brake = 0
            current_vehicle.engine_force = -input_dir.y * 2500.0
            
        current_vehicle.steering = -input_dir.x * 0.6
        global_position = current_vehicle.global_position + Vector3(0, 3.0, 0)
        mesh_root.visible = false
        return

    mesh_root.visible = true
    if not is_on_floor(): velocity.y -= gravity * delta

    var direction = (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    direction.y = 0
    direction = direction.normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        var target_angle = atan2(-direction.x, -direction.z)
        mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_angle, 0.2)
        
        walk_time += delta * 15.0
        left_leg.rotation.x = sin(walk_time) * 0.7
        right_leg.rotation.x = -sin(walk_time) * 0.7
        left_arm.rotation.x = -sin(walk_time) * 0.5
        right_arm.rotation.x = sin(walk_time) * 0.5
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
        left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 0.2)
        right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 0.2)
        left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 0.2)
        right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 0.2)

    move_and_slide()

func jump():
    if is_on_floor() and not current_vehicle:
        velocity.y = jump_force

func shoot():
    if current_vehicle or ammo <= 0: return
    ammo -= 1
    
    weapon.visible = true
    await get_tree().create_timer(0.1).timeout
    weapon.visible = false

    var space_state = get_world_3d().direct_space_state
    var screen_center = get_viewport().get_visible_rect().size / 2
    var origin = camera.project_ray_origin(screen_center)
    var end = origin + camera.project_ray_normal(screen_center) * 100
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    query.exclude = [self.get_rid()]
    var result = space_state.intersect_ray(query)
    
    var tracer = MeshInstance3D.new()
    var t_mesh = BoxMesh.new()
    t_mesh.size = Vector3(0.05, 0.05, origin.distance_to(end))
    tracer.mesh = t_mesh
    var t_mat = StandardMaterial3D.new()
    t_mat.albedo_color = Color(1, 1, 0, 0.8)
    t_mat.emission_enabled = true
    t_mat.emission = Color(1, 1, 0)
    tracer.material_override = t_mat
    get_tree().current_scene.add_child(tracer)
    tracer.global_position = (origin + end) / 2
    tracer.look_at(end, Vector3.UP)
    get_tree().create_timer(0.1).timeout.connect(tracer.queue_free)

    var main = get_node_or_null("../../Main")
    if main: 
        main.add_wanted_level()
        main.panic_pedestrians()

    if result and result.collider.has_method("take_damage"):
        result.collider.take_damage(50)

func switch_weapon():
    weapon_type = 2 if weapon_type == 1 else 1
    var main = get_node_or_null("../../Main")
    if main:
        main.hud_weapon.text = "WEAPON: " + ("PISTOL" if weapon_type == 1 else "SMG")

func interact():
    if current_vehicle:
        current_vehicle = null
    else:
        var vehicles = get_tree().get_nodes_in_group("vehicles")
        for v in vehicles:
            if global_position.distance_to(v.global_position) < 8.0:
                current_vehicle = v
                break

func take_damage(amount: float):
    health -= amount
    if health <= 0: get_tree().reload_current_scene()

func add_money(amount: int): money += amount
func add_ammo(amount: int): ammo += amount
func add_health(amount: float): health = min(100.0, health + amount)
