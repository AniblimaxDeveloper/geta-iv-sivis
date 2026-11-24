extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var sun = $DirectionalLight3D

var wanted_level: int = 0
var police_spawned: bool = false

func _ready():
    generate_city()
    spawn_vehicles(15)
    spawn_pedestrians(40)

func _process(_delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_wanted.text = "WANTED: " + str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)

func generate_city():
    # 1. Lantai Aspal
    var ground = StaticBody3D.new()
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(800, 800)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_color = Color(0.12, 0.12, 0.15)
    floor_mesh.material_override = f_mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(800, 1, 800)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(floor_mesh)
    ground.add_child(col)
    add_child(ground)

    # 2. Grid Gedung & Jalan
    var block_size = 100
    for x in range(-3, 4):
        for z in range(-3, 4):
            # Bangunan
            var b = StaticBody3D.new()
            var m = MeshInstance3D.new()
            var b_box = BoxMesh.new()
            var w = randf_range(30, 50)
            var h = randf_range(60, 200)
            var d = randf_range(30, 50)
            b_box.size = Vector3(w, h, d)
            m.mesh = b_box
            
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.15, 0.15, 0.2)
            mat.emission_enabled = true
            mat.emission = Color(0.2, 0.5, 0.8) * randf_range(0.1, 0.4) # Jendela biru
            m.material_override = mat
            
            var c = CollisionShape3D.new()
            var s = BoxShape3D.new()
            s.size = b_box.size
            c.shape = s
            
            b.position = Vector3(x * block_size, h / 2, z * block_size)
            b.add_child(m)
            b.add_child(c)
            add_child(b)

            # Marka Jalan (Garis Putih)
            for i in range(-4, 5):
                var line = MeshInstance3D.new()
                var l_box = BoxMesh.new()
                l_box.size = Vector3(0.5, 0.05, 20)
                line.mesh = l_box
                var l_mat = StandardMaterial3D.new()
                l_mat.albedo_color = Color(1, 1, 1, 0.5)
                line.material_override = l_mat
                # Posisi di tengah jalan antar gedung
                line.position = Vector3(x * block_size + block_size/2, 0.02, i * 20 + z * block_size)
                add_child(line)

    # 3. Pohon Palem
    for i in range(50):
        var palm = Node3D.new()
        var trunk = MeshInstance3D.new()
        var cyl = CylinderMesh.new()
        cyl.top_radius = 0.5
        cyl.bottom_radius = 0.8
        cyl.height = 12.0
        trunk.mesh = cyl
        trunk.position.y = 6.0
        var trunk_mat = StandardMaterial3D.new()
        trunk_mat.albedo_color = Color(0.4, 0.2, 0.1)
        trunk.material_override = trunk_mat
        palm.add_child(trunk)
        
        var leaves = MeshInstance3D.new()
        var sphere = SphereMesh.new()
        sphere.radius = 4.0
        sphere.height = 1.5
        leaves.mesh = sphere
        leaves.position.y = 12.0
        var leaf_mat = StandardMaterial3D.new()
        leaf_mat.albedo_color = Color(0.1, 0.6, 0.2)
        leaves.material_override = leaf_mat
        palm.add_child(leaves)
        
        palm.position = Vector3(randf_range(-300, 300), 0, randf_range(-300, 300))
        add_child(palm)

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
        mat.albedo_color = Color(randf(), 0.1, randf())
        mesh.material_override = mat
        car.add_child(mesh)
        for w in [[1.2, -0.5, 1.8], [-1.2, -0.5, 1.8], [1.2, -0.5, -1.8], [-1.2, -0.5, -1.8]]:
            var wheel = VehicleWheel3D.new()
            wheel.position = Vector3(w[0], w[1], w[2])
            wheel.use_as_steering = true
            wheel.use_as_traction = true
            car.add_child(wheel)
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
        ped.position = Vector3(randf_range(-200, 200), 1.0, randf_range(-200, 200))
        add_child(ped)

func panic_pedestrians():
    var peds = get_tree().get_nodes_in_group("pedestrians") # Pastikan masuk grup
    for p in peds:
        if p.has_method("panic"):
            p.panic()

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
