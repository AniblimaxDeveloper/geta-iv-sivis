extends VehicleBody3D
var target_speed: float = 600.0
var time: float = 0.0
var ray: RayCast3D
var health: float = 100.0

func _ready():
    add_to_group("vehicles")
    ray = RayCast3D.new()
    ray.target_position = Vector3(0, 0, -10)
    add_child(ray)

func _physics_process(delta):
    if health <= 0: return
    
    if ray.is_colliding():
        brake = 20.0
        engine_force = 0
    else:
        brake = 0
        engine_force = target_speed
        
    time += delta
    if time > randf_range(4.0, 8.0):
        time = 0
        steering = randf_range(-0.4, 0.4)

func take_damage(amount: float):
    health -= amount
    var mat = $MeshInstance3D.material_override as StandardMaterial3D
    if mat:
        mat.albedo_color = Color(1, 0, 0) # Berkedip merah saat tertembak
        await get_tree().create_timer(0.1).timeout
        if health > 0:
            mat.albedo_color = Color(randf(), 0.1, randf())
        else:
            explode()

func explode():
    # Efek Ledakan (Cahaya)
    var light = OmniLight3D.new()
    light.light_color = Color(1, 0.5, 0)
    light.light_energy = 20.0
    light.omni_range = 30.0
    add_child(light)
    
    # Sembunyikan mobil
    $MeshInstance3D.visible = false
    engine_force = 0
    brake = 20.0
    
    await get_tree().create_timer(1.0).timeout
    queue_free()
