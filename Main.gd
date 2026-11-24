extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel

var wanted_level: int = 0
var police_spawned: bool = false

func _ready():
    generate_world()
    spawn_vehicles(20)
    spawn_pedestrians(30)

func _process(_delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_armor.value = player.armor
    hud_stamina.value = player.stamina
    hud_wanted.text = str(wanted_level) + " ★"

func generate_world():
    # Lantai Dasar
    var ground = StaticBody3D.new()
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(2000, 2000)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_color = Color(0.15, 0.15, 0.2)
    floor_mesh.material_override = f_mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(2000, 1, 2000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(floor_mesh)
    ground.add_child(col)
    add_child(ground)

    # ZONA 1: KOTA (X > 0, Z > 0)
    for x in range(1, 8):
        for z in range(1, 8):
            var b = StaticBody3D.new()
            var m = MeshInstance3D.new()
            var b_box = BoxMesh.new()
            var h = randf_range(50, 200)
            b_box.size = Vector3(30, h, 30)
            m.mesh = b_box
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.1, 0.1, 0.15)
            mat.emission_enabled = true
            mat.emission = Color(0.2, 0.5, 0.8)
            m.material_override = mat
            b.position = Vector3(x * 80, h/2, z * 80)
            b.add_child(m)
            add_child(b)

    # ZONA 2: PANTAI (X < 0, Z > 0)
    for x in range(-8, 0):
        for z in range(1, 8):
            var palm = Node3D.new()
            var trunk = MeshInstance3D.new()
            var cyl = CylinderMesh.new()
            cyl.height = 15.0
            trunk.mesh = cyl
            trunk.position.y = 7.5
            var t_mat = StandardMaterial3D.new()
            t_mat.albedo_color = Color(0.4, 0.2, 0.1)
            trunk.material_override = t_mat
            palm.add_child(trunk)
            palm.position = Vector3(x * 80, 0, z * 80)
            add_child(palm)

    # ZONA 3: GUNUNG (X < 0, Z < 0)
    for x in range(-8, 0):
        for z in range(-8, 0):
            var mount = MeshInstance3D.new()
            var cyl = CylinderMesh.new()
            cyl.top_radius = 0.1
            cyl.bottom_radius = randf_range(30, 60)
            cyl.height = randf_range(100, 250)
            mount.mesh = cyl
            var m_mat = StandardMaterial3D.new()
            m_mat.albedo_color = Color(0.2, 0.3, 0.2)
            mount.material_override = m_mat
            mount.position = Vector3(x * 80, cyl.height/2, z * 80)
            add_child(mount)

    # ZONA 4: PELABUHAN (X > 0, Z < 0)
    for x in range(1, 8):
        for z in range(-8, 0):
            var container = StaticBody3D.new()
            var m = MeshInstance3D.new()
            var b_box = BoxMesh.new()
            b_box.size = Vector3(40, 10, 20)
            m.mesh = b_box
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(randf(), randf(), randf())
            m.material_override = mat
            container.position = Vector3(x * 80, 5, z * 80)
            container.add_child(m)
            add_child(container)

func spawn_vehicles(amount: int):
    for i in range(amount):
        var car = VehicleBody3D.new()
        car.set_script(load("res://TrafficCar.gd"))
        var col = CollisionShape3D.new()
        var box = BoxShape3D.new()
        box.size = Vector3(2.5, 1.5, 5.0)
        col.shape = box
        car.add_child(col)
        var mesh = MeshInstance3D.new()
        mesh.name = "MeshInstance3D"
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
        car.position = Vector3(randf_range(100, 500), 2.0, randf_range(100, 500)) # Spawn di Kota
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
        
        # 10 Karakter Berbeda (Warna Baju Acak)
        var torso = MeshInstance3D.new()
        torso.mesh = CapsuleMesh.new()
        var t_mat = StandardMaterial3D.new()
        t_mat.albedo_color = Color(randf(), randf(), randf())
        torso.material_override = t_mat
        torso.position.y = 1.0
        mesh_root.add_child(torso)
        
        var head = MeshInstance3D.new()
        head.mesh = SphereMesh.new()
        head.position.y = 1.9
        mesh_root.add_child(head)
        
        ped.add_child(mesh_root)
        ped.position = Vector3(randf_range(100, 500), 1.0, randf_range(100, 500)) # Spawn di Kota
        add_child(ped)
