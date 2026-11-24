extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_wanted = $UI/WantedLabel
@onready var sun = $DirectionalLight3D

var wanted_level: int = 0
var police_spawned: bool = false
var time: float = 0.0

func _ready():
    generate_city()
    spawn_collectables(30)
    spawn_vehicles(5)

func _process(delta):
    hud_money.text = "CASH: $" + str(player.money)
    hud_wanted.text = "WANTED: " + str(wanted_level) + " ★"
    
    # Siklus Siang-Malam perlahan
    time += delta * 0.05
    sun.rotation.x = sin(time) * 1.2

func generate_city():
    # Lantai Aspal Gelap
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(400, 400)
    floor_mesh.mesh = plane
    var floor_mat = StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.1, 0.1, 0.15)
    floor_mesh.material_override = floor_mat
    add_child(floor_mesh)

    # Gedung Neon ala GTA VI
    for i in range(100):
        var building = StaticBody3D.new()
        var mesh = MeshInstance3D.new()
        var box = BoxMesh.new()
        var w = randf_range(15, 40)
        var h = randf_range(30, 100)
        var d = randf_range(15, 40)
        box.size = Vector3(w, h, d)
        mesh.mesh = box
        
        var mat = StandardMaterial3D.new()
        # Warna ungu, pink, biru neon
        mat.albedo_color = Color(randf_range(0.1, 0.4), randf_range(0.1, 0.2), randf_range(0.4, 0.8))
        mat.emission_enabled = true
        mat.emission = Color(1.0, 0.2, 0.8) * randf_range(0.2, 0.6)
        mesh.material_override = mat
        
        var collision = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = box.size
        collision.shape = shape
        
        building.position = Vector3(randf_range(-180, 180), h / 2, randf_range(-180, 180))
        building.add_child(mesh)
        building.add_child(collision)
        add_child(building)

func spawn_vehicles(amount: int):
    for i in range(amount):
        var car = VehicleBody3D.new()
        car.add_to_group("vehicles")
        
        var col = CollisionShape3D.new()
        var box = BoxShape3D.new()
        box.size = Vector3(2, 1, 4)
        col.shape = box
        car.add_child(col)
        
        var mesh = MeshInstance3D.new()
        var box_mesh = BoxMesh.new()
        box_mesh.size = Vector3(2, 1, 4)
        mesh.mesh = box_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(1, 0.1, 0.5) # Mobil Pink Neon
        mesh.material_override = mat
        car.add_child(mesh)
        
        # Roda Mobil
        for w in [[0.9, -0.5, 1.5], [-0.9, -0.5, 1.5], [0.9, -0.5, -1.5], [-0.9, -0.5, -1.5]]:
            var wheel = VehicleWheel3D.new()
            wheel.position = Vector3(w[0], w[1], w[2])
            wheel.use_as_steering = true
            wheel.use_as_traction = true
            car.add_child(wheel)
            
        car.position = Vector3(randf_range(-100, 100), 1.0, randf_range(-100, 100))
        add_child(car)

func spawn_collectables(amount: int):
    for i in range(amount):
        var coin = Area3D.new()
        var col = CollisionShape3D.new()
        var sphere = SphereShape3D.new()
        sphere.radius = 1.0
        col.shape = sphere
        
        var mesh = MeshInstance3D.new()
        var sphere_mesh = SphereMesh.new()
        mesh.mesh = sphere_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0, 1, 0)
        mat.emission_enabled = true
        mat.emission = Color(0, 1, 0)
        mesh.material_override = mat
        
        coin.position = Vector3(randf_range(-150, 150), 1.5, randf_range(-150, 150))
        coin.add_child(mesh)
        coin.add_child(col)
        coin.body_entered.connect(_on_coin_collected.bind(coin))
        add_child(coin)

func _on_coin_collected(body, coin):
    if body == player:
        player.add_money(100)
        coin.queue_free()

func add_wanted_level():
    wanted_level += 1
    if wanted_level == 1 and not police_spawned:
        spawn_police(5)
        police_spawned = true

func spawn_police(amount: int):
    for i in range(amount):
        var police = CharacterBody3D.new()
        police.set_script(load("res://Police.gd"))
        
        var col = CollisionShape3D.new()
        var cap = CapsuleShape3D.new()
        col.shape = cap
        police.add_child(col)
        
        var mesh = MeshInstance3D.new()
        var cap_mesh = CapsuleMesh.new()
        mesh.mesh = cap_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0, 0.5, 1) # Polisi Biru
        mesh.material_override = mat
        police.add_child(mesh)
        
        police.position = Vector3(player.position.x + randf_range(-30, 30), 2.0, player.position.z + randf_range(-30, 30))
        add_child(police)
