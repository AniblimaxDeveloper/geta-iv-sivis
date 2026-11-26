extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var hud_mission = $UI/MissionLabel
@onready var radar = $UI/Radar
@onready var sun = $DirectionalLight3D
@onready var env = $WorldEnvironment

var wanted_level: int = 0
var police_spawned: bool = false
var time_of_day: float = 0.0
var weather_timer: float = 0.0
var is_raining: bool = false
var rain_particles: CPUParticles3D = null

func _ready():
    generate_world()
    spawn_traffic(15)
    spawn_peds(20)
    setup_rain()
    spawn_bank_mission()

func _process(delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_armor.value = player.armor
    hud_stamina.value = player.stamina
    hud_wanted.text = str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)
    radar.queue_redraw()
    
    time_of_day += delta * 0.02
    sun.rotation.x = sin(time_of_day) * 1.2
    
    # Siklus Cuaca (Hujan tiap 20 detik)
    weather_timer += delta
    if weather_timer > 20.0:
        weather_timer = 0
        is_raining = not is_raining
        if is_raining:
            rain_particles.emitting = true
            env.environment.fog_enabled = true
            env.environment.fog_density = 0.05
            env.environment.fog_light_color = Color(0.2, 0.2, 0.3) # Gelap
            sun.light_energy = 0.5 # Redup
        else:
            rain_particles.emitting = false
            env.environment.fog_enabled = false
            sun.light_energy = 1.5

func setup_rain():
    rain_particles = CPUParticles3D.new()
    rain_particles.emitting = false
    rain_particles.amount = 2000
    rain_particles.lifetime = 1.0
    rain_particles.direction = Vector3(0, -1, 0)
    rain_particles.spread = 10.0
    rain_particles.initial_velocity_min = 20.0
    rain_particles.initial_velocity_max = 30.0
    rain_particles.gravity = Vector3(0, -20, 0)
    rain_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
    rain_particles.emission_box_extents = Vector3(50, 30, 50)
    
    var mesh = BoxMesh.new()
    mesh.size = Vector3(0.05, 0.5, 0.05) # Bentuk tetesan air
    rain_particles.mesh = mesh
    
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.5, 0.6, 0.8, 0.6)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    rain_particles.material_override = mat
    
    add_child(rain_particles)

func generate_world():
    # Lantai
    var ground = StaticBody3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(1000, 1000)
    var m = MeshInstance3D.new()
    m.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.15, 0.15, 0.18)
    m.material_override = mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1000, 1, 1000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(m)
    ground.add_child(col)
    add_child(ground)

    # Gedung & Lampu
    for x in range(-4, 5):
        for z in range(-4, 5):
            if x == 0 and z == 0: continue
            var b = StaticBody3D.new()
            var h = randf_range(40, 150)
            var box = BoxMesh.new()
            box.size = Vector3(35, h, 35)
            var b_m = MeshInstance3D.new()
            b_m.mesh = box
            var b_mat = StandardMaterial3D.new()
            b_mat.albedo_color = Color(0.1, 0.1, 0.15)
            b_mat.emission_enabled = true
            b_mat.emission = Color(0.1, 0.3, 0.7)
            b_m.material_override = b_mat
            
            var c = CollisionShape3D.new()
            var s = BoxShape3D.new()
            s.size = box.size
            c.shape = s
            
            b.position = Vector3(x * 70, h/2, z * 70)
            b.add_child(b_m)
            b.add_child(c)
            add_child(b)

func spawn_bank_mission():
    # Gedung Bank (Warna Emas/Menyala)
    var bank = Area3D.new()
    bank.add_to_group("bank")
    
    var col = CollisionShape3D.new()
    var box = BoxShape3D.new()
    box.size = Vector3(20, 20, 20)
    col.shape = box
    bank.add_child(col)
    
    var mesh = MeshInstance3D.new()
    var b_mesh = BoxMesh.new()
    b_mesh.size = Vector3(20, 20, 20)
    mesh.mesh = b_mesh
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1, 0.8, 0)
    mat.emission_enabled = true
    mat.emission = Color(1, 0.8, 0)
    mesh.material_override = mat
    bank.add_child(mesh)
    
    bank.position = Vector3(randf_range(-150, 150), 10, randf_range(-150, 150))
    bank.body_entered.connect(_on_bank_robbed)
    add_child(bank)
    hud_mission.text = "MISSION: Rampok Gedung Emas!"

func _on_bank_robbed(body):
    if body.name == "Player":
        player.money += 50000
        # Set Wanted Level ke Maksimal
        wanted_level = 5
        hud_wanted.text = "5 ★"
        spawn_police_wave(10) # Spawn 10 Polisi sekaligus!
        hud_mission.text = "BANK ROBBED! KABUR DARI POLISI!"
        # Hapus gedung bank setelah dirampok
        var bank = get_tree().get_first_node_in_group("bank")
        if bank: bank.queue_free()

func spawn_police_wave(amt: int):
    for i in range(amt):
        var police = CharacterBody3D.new()
        police.add_to_group("police")
        police.set_script(load("res://Police.gd"))
        var c = CollisionShape3D.new()
        c.shape = CapsuleShape3D.new()
        police.add_child(c)
        var m = MeshInstance3D.new()
        m.mesh = CapsuleMesh.new()
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0, 0.2, 1)
        m.material_override = mat
        police.add_child(m)
        police.position = Vector3(player.position.x + randf_range(-40, 40), 2.0, player.position.z + randf_range(-40, 40))
        add_child(police)
    police_spawned = true

func spawn_traffic(amt: int):
    for i in range(amt):
        var car = VehicleBody3D.new()
        car.add_to_group("vehicles")
        car.set_script(load("res://TrafficCar.gd"))
        var col = CollisionShape3D.new()
        var box = BoxShape3D.new()
        box.size = Vector3(2.5, 1.5, 5.0)
        col.shape = box
        car.add_child(col)
        var mesh = MeshInstance3D.new()
        mesh.name = "MeshInstance3D"
        var b_mesh = BoxMesh.new()
        b_mesh.size = Vector3(2.5, 1.5, 5.0)
        mesh.mesh = b_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(randf(), 0.1, randf())
        mesh.material_override = mat
        car.add_child(mesh)
        for w in [[1.2, -0.5, 1.8], [-1.2, -0.5, 1.8], [1.2, -0.5, -1.8], [-1.2, -0.5, -1.8]]:
            var wheel = VehicleWheel3D.new()
            wheel.position = Vector3(w[0], w[1], w[2])
            wheel.use_as_steering = true
            wheel.use_as_traction = true
            car.add_child(wheel)
        car.position = Vector3(randf_range(100, 400), 2.0, randf_range(-300, 300))
        add_child(car)

func spawn_peds(amt: int):
    for i in range(amt):
        var ped = CharacterBody3D.new()
        ped.add_to_group("pedestrians")
        ped.set_script(load("res://Pedestrian.gd"))
        var col = CollisionShape3D.new()
        col.shape = CapsuleShape3D.new()
        ped.add_child(col)
        var root = Node3D.new()
        root.name = "MeshRoot"
        var body = MeshInstance3D.new()
        body.mesh = CapsuleMesh.new()
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(randf(), randf(), randf())
        body.material_override = mat
        body.position.y = 1.0
        root.add_child(body)
        var head = MeshInstance3D.new()
        head.mesh = SphereMesh.new()
        head.position.y = 1.9
        root.add_child(head)
        ped.add_child(root)
        ped.position = Vector3(randf_range(100, 400), 1.0, randf_range(-300, 300))
        add_child(ped)

func panic_pedestrians():
    for p in get_tree().get_nodes_in_group("pedestrians"):
        if p.has_method("panic"): p.panic()

func add_wanted_level():
    wanted_level += 1
    if wanted_level == 1 and not police_spawned:
        spawn_police_wave(5)
