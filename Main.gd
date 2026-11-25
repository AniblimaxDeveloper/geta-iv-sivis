extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var radar = $UI/Radar
@onready var sun = $DirectionalLight3D
@onready var env = $WorldEnvironment

var wanted_level: int = 0
var police_spawned: bool = false
var time_of_day: float = 0.0
var weather_timer: float = 0.0

func _ready():
    generate_world()
    spawn_traffic(20)
    spawn_peds(30)
    spawn_robbery_target()

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
    
    # Sistem Cuaca Dinamis
    weather_timer += delta
    if weather_timer > 30.0: # Ganti cuaca tiap 30 detik
        weather_timer = 0
        Global.is_raining = not Global.is_raining
        if Global.is_raining:
            env.environment.fog_enabled = true
            env.environment.fog_density = 0.05
            env.environment.fog_light_color = Color(0.3, 0.3, 0.35) # Langit gelap
        else:
            env.environment.fog_enabled = false

func generate_world():
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

    for x in range(-4, 5):
        for z in range(-4, 5):
            if x == 0 and z == 0: continue
            var b = StaticBody3D.new()
            var h = randf_range(50, 180)
            var box = BoxMesh.new()
            box.size = Vector3(40, h, 40)
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
            
            b.position = Vector3(x * 80, h/2, z * 80)
            b.add_child(b_m)
            b.add_child(c)
            add_child(b)

func spawn_robbery_target():
    # Toko Perampokan (Tiang Hijau)
    var store = Area3D.new()
    store.add_to_group("robbery")
    
    var col = CollisionShape3D.new()
    var cyl = CylinderShape3D.new()
    cyl.radius = 5.0
    cyl.height = 15.0
    col.shape = cyl
    store.add_child(col)
    
    var mesh = MeshInstance3D.new()
    var cyl_mesh = CylinderMesh.new()
    cyl_mesh.top_radius = 5.0
    cyl_mesh.bottom_radius = 5.0
    cyl_mesh.height = 15.0
    mesh.mesh = cyl_mesh
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0, 1, 0)
    mat.emission_enabled = true
    mat.emission = Color(0, 1, 0)
    mesh.material_override = mat
    store.add_child(mesh)
    
    store.position = Vector3(randf_range(-150, 150), 7.5, randf_range(-150, 150))
    store.body_entered.connect(_on_store_robbed)
    add_child(store)

func _on_store_robbed(body):
    if body.name == "Player":
        player.money += 15000
        add_wanted_level() # Merampok bikin polisi datang
        # Pindahkan toko ke tempat baru
        get_tree().get_first_node_in_group("robbery").position = Vector3(randf_range(-150, 150), 7.5, randf_range(-150, 150))

func spawn_traffic(amt: int):
    for i in range(amt):
        var car = VehicleBody3D.new()
        car.add_to_group("vehicles")
        var col = CollisionShape3D.new()
        var box = BoxShape3D.new()
        box.size = Vector3(2.5, 1.5, 5.0)
        col.shape = box
        car.add_child(col)
        var mesh = MeshInstance3D.new()
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
        # Spawn Polisi Darat
        for i in range(5):
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
            police.position = Vector3(player.position.x + randf_range(-30, 30), 2.0, player.position.z + randf_range(-30, 30))
            add_child(police)
            
        # Spawn Helikopter Polisi
        var heli = CharacterBody3D.new()
        heli.set_script(load("res://Helicopter.gd"))
        var hc = CollisionShape3D.new()
        hc.shape = BoxShape3D.new()
        heli.add_child(hc)
        var hm = MeshInstance3D.new()
        var hbox = BoxMesh.new()
        hbox.size = Vector3(4, 2, 6)
        hm.mesh = hbox
        var hmat = StandardMaterial3D.new()
        hmat.albedo_color = Color(0, 0.2, 1)
        hm.material_override = hmat
        heli.add_child(hm)
        heli.position = Vector3(player.position.x, 50, player.position.z) # Di langit
        add_child(heli)
        
        police_spawned = true
