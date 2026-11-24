extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthLabel

func _ready():
    generate_city()
    spawn_collectables(40)
    spawn_enemies(15)

func _process(_delta):
    hud_money.text = "CASH: $" + str(player.money)

func generate_city():
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(400, 400)
    floor_mesh.mesh = plane
    var floor_mat = StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.1, 0.12, 0.15)
    floor_mesh.material_override = floor_mat
    add_child(floor_mesh)

    for i in range(120):
        var building = StaticBody3D.new()
        var mesh = MeshInstance3D.new()
        var box = BoxMesh.new()
        var w = randf_range(10, 30)
        var h = randf_range(20, 80)
        var d = randf_range(10, 30)
        box.size = Vector3(w, h, d)
        mesh.mesh = box
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(randf_range(0.1, 0.3), randf_range(0.1, 0.3), randf_range(0.2, 0.4))
        mesh.material_override = mat
        var collision = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = box.size
        collision.shape = shape
        building.position = Vector3(randf_range(-180, 180), h / 2, randf_range(-180, 180))
        building.add_child(mesh)
        building.add_child(collision)
        add_child(building)

func spawn_collectables(amount: int):
    for i in range(amount):
        var coin = Area3D.new()
        var collision = CollisionShape3D.new()
        var sphere = SphereShape3D.new()
        var mesh = MeshInstance3D.new()
        var sphere_mesh = SphereMesh.new()
        sphere.radius = 1.0
        collision.shape = sphere
        sphere_mesh.radius = 1.0
        sphere_mesh.height = 2.0
        mesh.mesh = sphere_mesh
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0, 1, 0)
        mat.emission_enabled = true
        mat.emission = Color(0, 1, 0)
        mesh.material_override = mat
        coin.position = Vector3(randf_range(-150, 150), 1.5, randf_range(-150, 150))
        coin.add_child(mesh)
        coin.add_child(collision)
        coin.body_entered.connect(_on_coin_collected.bind(coin))
        add_child(coin)

func spawn_enemies(amount: int):
    for i in range(amount):
        var enemy = CharacterBody3D.new()
        enemy.set_script(load("res://Enemy.gd"))
        
        var col = CollisionShape3D.new()
        var shape = CapsuleShape3D.new()
        shape.radius = 0.5
        shape.height = 2.0
        col.shape = shape
        
        var mesh = MeshInstance3D.new()
        var cap_mesh = CapsuleMesh.new()
        cap_mesh.radius = 0.5
        cap_mesh.height = 2.0
        mesh.mesh = cap_mesh
        
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(1, 0.2, 0.2) # Warna Merah
        mesh.material_override = mat
        
        enemy.add_child(col)
        enemy.add_child(mesh)
        enemy.position = Vector3(randf_range(-100, 100), 2.0, randf_range(-100, 100))
        add_child(enemy)

func _on_coin_collected(body, coin):
    if body == player:
        player.add_money(100)
        coin.queue_free()
