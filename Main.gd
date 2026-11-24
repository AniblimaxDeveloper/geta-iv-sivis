extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_wanted = $UI/WantedLabel

var wanted_level: int = 0
var police_spawned: bool = false

func _ready():
    generate_smart_city()
    spawn_vehicles(8)
    spawn_pedestrians(30)

func _process(_delta):
    hud_money.text = "CASH: $" + str(player.money)
    hud_wanted.text = "WANTED: " + str(wanted_level) + " ★"

func generate_smart_city():
    # 1. Lantai Aspal Raksasa
    var floor = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(500, 500)
    floor.mesh = plane
    var floor_mat = StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.08, 0.08, 0.1)
    floor.material_override = floor_mat
    add_child(floor)

    # 2. Generate Blok Kota (Grid)
    var block_size = 60
    for x in range(-4, 5):
        for z in range(-4, 5):
            # Acak apakah ini Gedung atau Taman
            if randf() > 0.2:
                var building = StaticBody3D.new()
                var mesh = MeshInstance3D.new()
                var box = BoxMesh.new()
                var w = randf_range(20, 40)
                var h = randf_range(40, 150)
                var d = randf_range(20, 40)
                box.size = Vector3(w, h, d)
                mesh.mesh = box
                
                var mat = StandardMaterial3D.new()
                mat.albedo_color = Color(randf_range(0.1, 0.3), randf_range(0.1, 0.2), randf_range(0.3, 0.6))
                mat.emission_enabled = true
                mat.emission = Color(1.0, 0.1, 0.8) * randf_range(0.1, 0.3) # Lampu Neon
                mesh.material_override = mat
                
                var collision = CollisionShape3D.new()
                var shape = BoxShape3D.new()
                shape.size = box.size
                collision.shape = shape
                
                building.position = Vector3(x * block_size, h / 2, z * block_size)
                building.add_child(mesh)
                building.add_child(collision)
                add_child(building)

    # 3. Garis Jalan (Kuning)
    for i in range(-4, 5):
        for j in range(-200, 200, 10):
            var line = MeshInstance3D.new()
            var box = BoxMesh.new()
            box.size = Vector3(0.5, 0.1, 4)
            line.mesh = box
            var line_mat = StandardMaterial3D.new()
            line_mat.albedo_color = Color(1, 0.8, 0)
            line.material_override = line_mat
            line.position = Vector3(i * block_size, 0.05, j)
            add_child(line)

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
        car.position = Vector3(randf_range(-100, 100), 2.0, randf_range(-100, 100))
        add_child(car)

func spawn_pedestrians(amount: int):
    for i in range(amount):
        var ped = CharacterBody3D.new()
        ped.set_script(load("res://Pedestrian.gd"))
        
        var col = CollisionShape3D.new()
        var cap = CapsuleShape3D.new()
        col.shape = cap
        ped.add_child(col)
        
        # Bentuk Manusia Prosedural
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
        spawn_police(6)
        police_spawned = true

func spawn_police(amount: int):
    for i in range(amount):
        var police = CharacterBody3D.new()
        police.set_script(load("res://Police.gd"))
        var col = CollisionShape3D.new()
        col.shape = CapsuleShape3D.new()
        police.add_child(col)
        var mesh = MeshInstance3D.new()
        mesh.mesh = CapsuleMesh.new()
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0, 0.2, 1)
        mesh.material_override = mat
        police.add_child(mesh)
        police.position = Vector3(player.position.x + randf_range(-40, 40), 2.0, player.position.z + randf_range(-40, 40))
        add_child(police)
