extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var sun = $DirectionalLight3D

var wanted_level: int = 0
var police_spawned: bool = false
var time_of_day: float = 0.0

func _ready():
    generate_city()
    spawn_vehicles(20)
    spawn_pedestrians(50)

func _process(delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_wanted.text = "WANTED: " + str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)
    
    time_of_day += delta * 0.05
    sun.rotation.x = sin(time_of_day) * 1.5

func generate_city():
    # 1. LANTAI ASPAL (Yang sekarang punya tabrakan fisik)
    var ground_body = StaticBody3D.new()
    
    # Visual Lantai
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(600, 600)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_color = Color(0.15, 0.15, 0.2) # Warna aspal agak terang
    floor_mesh.material_override = f_mat
    
    # Tabrakan Lantai (Collision)
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(600, 1, 600)
    col.shape = shape
    col.position = Vector3(0, -0.5, 0) # Posisi tabrakan agar permukaannya pas di Y=0
    
    ground_body.add_child(floor_mesh)
    ground_body.add_child(col)
    add_child(ground_body)

    # 2. Air Pantai
    var water = MeshInstance3D.new()
    var w_plane = PlaneMesh.new()
    w_plane.size = Vector2(1000, 1000)
    water.mesh = w_plane
    var w_mat = StandardMaterial3D.new()
    w_mat.albedo_color = Color(0.1, 0.4, 0.8)
    w_mat.metallic = 0.8
    w_mat.roughness = 0.1
    water.material_override = w_mat
    water.position = Vector3(0, -0.2, -400)
    add_child(water)

    # 3. Gedung & Lampu
    var block_size = 80
    for x in range(-3, 4):
        for z in range(-3, 4):
            var b = StaticBody3D.new()
            var m = MeshInstance3D.new()
            var b_box = BoxMesh.new()
            var w = randf_range(20, 40)
            var h = randf_range(50, 160)
            var d = randf_range(20, 40)
            b_box.size = Vector3(w, h, d)
            m.mesh = b_box
            
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.1, 0.15, 0.2)
            mat.emission_enabled = true
            mat.emission = Color(0.1, 0.4, 0.8) * randf_range(0.2, 0.5)
            m.material_override = mat
            
            var c = CollisionShape3D.new()
            var s = BoxShape3D.new()
            s.size = b_box.size
            c.shape = s
            
            b.position = Vector3(x * block_size, h / 2, z * block_size)
            b.add_child(m)
            b.add_child(c)
            add_child(b)
            
    for i in range(30):
        var light = OmniLight3D.new()
        light.light_color = Color(1.0, 0.2, 0.8) if randf() > 0.5 else Color(0.2, 0.8, 1.0)
        light.light_energy = 8.0
        light.omni_range = 30.0
        light.position = Vector3(randf_range(-250, 250), 10, randf_range(-250, 250))
        add_child(light)

func spawn_vehicles(amount: int):
    for i in range(amount):
        var car = VehicleBody3D.new()
        car.add_to_group("vehicles")
        car.set_script(load("res://TrafficCar.gd"))
        
        var col = CollisionShape3D.new()
        var box = BoxShape3D.new()
        box.size = Vector3(2.5, 1.5, 5.0)
        col.shape = box
        car.add_child(col)
        
        var mesh = MeshInstance3D.new()
        var box_mesh = BoxMesh.new()
        box_mesh.size = Vector3(2.5, 1.5, 5.0)
        mesh.mesh = box_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(randf(), 0.2, randf())
        mesh.material_override = mat
        car.add_child(mesh)
        
        var light = SpotLight3D.new()
        light.position = Vector3(0, 0, -2.5)
        light.spot_range = 20.0
        light.light_energy = 2.0
        car.add_child(light)
        
        for w in [[1.2, -0.5, 1.8], [-1.2, -0.5, 1.8], [1.2, -0.5, -1.8], [-1.2, -0.5, -1.8]]:
            var wheel = VehicleWheel3D.new()
            wheel.position = Vector3(w[0], w[1], w[2])
            wheel.use_as_steering = true
            wheel.use_as_traction = true
            car.add_child(wheel)
            
        # Posisi mobil dinaikkan sedikit agar tidak tembus aspal
        car.position = Vector3(randf_range(-200, 200), 2.0, randf_range(-200, 200))
        add_child(car)

func spawn_pedestrians(amount: int):
    for i in range(amount):
        var ped = CharacterBody3D.new()
        ped.set_script(load("res://Pedestrian.gd"))
        var col = CollisionShape3D.new()
        col.shape = CapsuleShape3D.new()
        ped.add_child(col)
        
        var mesh_root = Node3D.new()
        mesh_root.name = "MeshRoot"
        var torso = MeshInstance3D.new()
        torso.mesh = CapsuleMesh.new()
        torso.position.y = 1.0
        mesh_root.add_child(torso)
        
        var head = MeshInstance3D.new()
        head.mesh = SphereMesh.new()
        head.position.y = 1.9
        mesh_root.add_child(head)
        
        ped.add_child(mesh_root)
        # Posisi warga pas di atas aspal
        ped.position = Vector3(randf_range(-200, 200), 1.0, randf_range(-200, 200))
        add_child(ped)

func add_wanted_level():
    wanted_level += 1
    if wanted_level == 1 and not police_spawned:
        for i in range(8):
            var police = CharacterBody3D.new()
            police.add_to_group("police")
            police.set_script(load("res://Police.gd"))
            var c = CollisionShape3D.new()
            c.shape = CapsuleShape3D.new()
            police.add_child(c)
            var m = MeshInstance3D.new()
            m.name = "Mesh"
            m.mesh = CapsuleMesh.new()
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0, 0.2, 1)
            m.material_override = mat
            police.add_child(m)
            police.position = Vector3(player.position.x + randf_range(-40, 40), 2.0, player.position.z + randf_range(-40, 40))
            add_child(police)
        police_spawned = true
