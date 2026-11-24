extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_wanted = $UI/WantedLabel

var wanted_level: int = 0
var police_spawned: bool = false

func _ready():
    generate_miami_city()
    spawn_vehicles(8)
    spawn_pedestrians(30)

func _process(_delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_wanted.text = "WANTED: " + str(wanted_level) + " ★"

func generate_miami_city():
    # 1. Aspal Jalan
    var floor = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(500, 500)
    floor.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_color = Color(0.1, 0.1, 0.15)
    floor.material_override = f_mat
    add_child(floor)

    # 2. Blok Gedung & Pohon Palem
    var block_size = 60
    for x in range(-4, 5):
        for z in range(-4, 5):
            if randf() > 0.2:
                # Gedung Pencakar Langit
                var b = StaticBody3D.new()
                var m = MeshInstance3D.new()
                var box = BoxMesh.new()
                var w = randf_range(15, 30)
                var h = randf_range(40, 120)
                var d = randf_range(15, 30)
                box.size = Vector3(w, h, d)
                m.mesh = box
                var mat = StandardMaterial3D.new()
                mat.albedo_color = Color(0.1, 0.1, 0.2)
                mat.emission_enabled = true
                mat.emission = Color(1.0, 0.2, 0.8) * randf_range(0.2, 0.5) # Efek Neon
                m.material_override = mat
                var c = CollisionShape3D.new()
                var s = BoxShape3D.new()
                s.size = box.size
                c.shape = s
                b.position = Vector3(x * block_size, h / 2, z * block_size)
                b.add_child(m)
                b.add_child(c)
                add_child(b)
                
            else:
                # Pohon Palem
                var palm = Node3D.new()
                var trunk = MeshInstance3D.new()
                var cyl = CylinderMesh.new()
                cyl.top_radius = 0.5
                cyl.bottom_radius = 0.8
                cyl.height = 8.0
                trunk.mesh = cyl
                trunk.position.y = 4.0
                var trunk_mat = StandardMaterial3D.new()
                trunk_mat.albedo_color = Color(0.4, 0.2, 0.1)
                trunk.material_override = trunk_mat
                palm.add_child(trunk)
                
                var leaves = MeshInstance3D.new()
                var sphere = SphereMesh.new()
                sphere.radius = 3.0
                sphere.height = 1.0
                leaves.mesh = sphere
                leaves.position.y = 8.0
                var leaf_mat = StandardMaterial3D.new()
                leaf_mat.albedo_color = Color(0.1, 0.6, 0.2)
                leaves.material_override = leaf_mat
                palm.add_child(leaves)
                
                palm.position = Vector3(x * block_size, 0, z * block_size)
                add_child(palm)

    # 3. Lampu Jalan Neon
    for i in range(20):
        var light = OmniLight3D.new()
        light.light_color = Color(1.0, 0.2, 0.8) if randf() > 0.5 else Color(0.2, 0.8, 1.0)
        light.light_energy = 5.0
        light.omni_range = 20.0
        light.position = Vector3(randf_range(-200, 200), 8, randf_range(-200, 200))
        add_child(light)

func spawn_vehicles(amount: int):
    for i in range(amount):
        var car = VehicleBody3D.new()
        car.add_to_group("vehicles")
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
        mat.albedo_color = Color(randf(), 0.1, randf())
        mesh.material_override = mat
        car.add_child(mesh)
        for w in [[1.2, -0.5, 1.8], [-1.2, -0.5, 1.8], [1.2, -0.5, -1.8], [-1.2, -0.5, -1.8]]:
            var wheel = VehicleWheel3D.new()
            wheel.position = Vector3(w[0], w[1], w[2])
            wheel.use_as_steering = true
            wheel.use_as_traction = true
            car.add_child(wheel)
        car.position = Vector3(randf_range(-80, 80), 2.0, randf_range(-80, 80))
        add_child(car)

func spawn_pedestrians(amount: int):
    for i in range(amount):
        var ped = CharacterBody3D.new()
        ped.set_script(load("res://Pedestrian.gd"))
        var col = CollisionShape3D.new()
        var cap = CapsuleShape3D.new()
        col.shape = cap
        ped.add_child(col)
        
        # Bentuk Manusia Sederhana untuk NPC
        var mesh_root = Node3D.new()
        var body = MeshInstance3D.new()
        var cap_mesh = CapsuleMesh.new()
        cap_mesh.height = 1.2
        body.mesh = cap_mesh
        body.position.y = 1.0
        mesh_root.add_child(body)
        var head = MeshInstance3D.new()
        var sphere = SphereMesh.new()
        sphere.radius = 0.3
        head.mesh = sphere
        head.position.y = 1.9
        mesh_root.add_child(head)
        ped.add_child(mesh_root)
        
        ped.position = Vector3(randf_range(-150, 150), 1.0, randf_range(-150, 150))
        add_child(ped)

func add_wanted_level():
    wanted_level += 1
    if wanted_level == 1 and not police_spawned:
        for i in range(6):
            var police = CharacterBody3D.new()
            police.set_script(load("res://Police.gd"))
            var c = CollisionShape3D.new()
            var cap = CapsuleShape3D.new()
            c.shape = cap
            police.add_child(c)
            var m = MeshInstance3D.new()
            m.name = "Mesh"
            m.mesh = CapsuleMesh.new()
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0, 0.2, 1)
            m.material_override = mat
            police.add_child(m)
            police.position = Vector3(player.position.x + randf_range(-30, 30), 2.0, player.position.z + randf_range(-30, 30))
            add_child(police)
        police_spawned = true
