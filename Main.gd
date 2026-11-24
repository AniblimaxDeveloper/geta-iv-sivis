extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var radar = $UI/Radar
@onready var sun = $DirectionalLight3D

var wanted_level: int = 0
var police_spawned: bool = false
var time_of_day: float = 0.0

func _ready():
    generate_world()
    spawn_traffic(20)
    spawn_peds(30)

func _process(delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_stamina.value = player.stamina
    hud_wanted.text = str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)
    radar.queue_redraw()
    
    # Siklus Siang Malam
    time_of_day += delta * 0.02
    sun.rotation.x = sin(time_of_day) * 1.2

func generate_world():
    # Lantai
    var ground = StaticBody3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(1000, 1000)
    var m = MeshInstance3D.new()
    m.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.1, 0.1, 0.12)
    m.material_override = mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1000, 1, 1000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(m)
    ground.add_child(col)
    add_child(ground)

    # Lautan (Zona Pantai)
    var water = MeshInstance3D.new()
    var w_plane = PlaneMesh.new()
    w_plane.size = Vector2(500, 500)
    water.mesh = w_plane
    var w_mat = StandardMaterial3D.new()
    w_mat.albedo_color = Color(0.1, 0.3, 0.6)
    w_mat.roughness = 0.1
    water.material_override = w_mat
    water.position = Vector3(-500, -0.2, 0)
    add_child(water)

    # Kota (X > 0)
    for x in range(1, 6):
        for z in range(-4, 5):
            var b = StaticBody3D.new()
            var h = randf_range(40, 150)
            var box = BoxMesh.new()
            box.size = Vector3(40, h, 40)
            var b_m = MeshInstance3D.new()
            b_m.mesh = box
            var b_mat = StandardMaterial3D.new()
            b_mat.albedo_color = Color(0.15, 0.15, 0.2)
            b_mat.emission_enabled = true
            b_mat.emission = Color(0.1, 0.3, 0.6)
            b_m.material_override = b_mat
            b.position = Vector3(x * 80, h/2, z * 80)
            b.add_child(b_m)
            add_child(b)

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
        
        var leg_l = MeshInstance3D.new()
        leg_l.name = "LegL"
        var l_box = BoxMesh.new()
        l_box.size = Vector3(0.2, 0.8, 0.2)
        leg_l.mesh = l_box
        leg_l.position = Vector3(0.2, 0.0, 0)
        root.add_child(leg_l)
        
        var leg_r = MeshInstance3D.new()
        leg_r.name = "LegR"
        leg_r.mesh = l_box
        leg_r.position = Vector3(-0.2, 0.0, 0)
        root.add_child(leg_r)
        
        ped.add_child(root)
        ped.position = Vector3(randf_range(100, 400), 1.0, randf_range(-300, 300))
        add_child(ped)

func panic_pedestrians():
    for p in get_tree().get_nodes_in_group("pedestrians"):
        if p.has_method("panic"): p.panic()

func add_wanted_level():
    wanted_level += 1
    if wanted_level == 1 and not police_spawned:
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
        police_spawned = true
