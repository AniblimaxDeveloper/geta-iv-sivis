extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel

var wanted_level: int = 0
var police_spawned: bool = false

func _ready():
    generate_world()
    spawn_vehicles(15)
    # Terapkan warna karakter
    var col = Global.char_colors[Global.selected_char]
    player.get_node("MeshRoot/Body").material_override.albedo_color = col

func _process(_delta):
    hud_money.text = "$" + str(Global.money)
    hud_health.value = Global.health
    hud_armor.value = Global.armor
    hud_stamina.value = Global.stamina
    hud_wanted.text = str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)

func generate_world():
    # 1. Lantai Aspal
    var ground = StaticBody3D.new()
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(1000, 1000)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_color = Color(0.1, 0.1, 0.12)
    floor_mesh.material_override = f_mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1000, 1, 1000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(floor_mesh)
    ground.add_child(col)
    add_child(ground)

    # 2. Grid Kota
    var block_size = 80
    for x in range(-4, 5):
        for z in range(-4, 5):
            # Trotoar
            var sidewalk = MeshInstance3D.new()
            var s_box = BoxMesh.new()
            s_box.size = Vector3(60, 0.2, 60)
            sidewalk.mesh = s_box
            var s_mat = StandardMaterial3D.new()
            s_mat.albedo_color = Color(0.2, 0.2, 0.25)
            sidewalk.material_override = s_mat
            sidewalk.position = Vector3(x * block_size, 0.1, z * block_size)
            add_child(sidewalk)

            # Gedung
            var b = StaticBody3D.new()
            var m = MeshInstance3D.new()
            var b_box = BoxMesh.new()
            var h = randf_range(40, 150)
            b_box.size = Vector3(40, h, 40)
            m.mesh = b_box
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.1, 0.1, 0.15)
            mat.emission_enabled = true
            mat.emission = Color(0.2, 0.4, 0.8)
            m.material_override = mat
            
            var c = CollisionShape3D.new()
            var s = BoxShape3D.new()
            s.size = b_box.size
            c.shape = s
            
            b.position = Vector3(x * block_size, h/2, z * block_size)
            b.add_child(m)
            b.add_child(c)
            add_child(b)

            # Lampu Jalan (Menyala)
            var light = OmniLight3D.new()
            light.light_color = Color(1, 0.8, 0.4)
            light.light_energy = 5.0
            light.omni_range = 25.0
            light.position = Vector3(x * block_size + 30, 10, z * block_size + 30)
            add_child(light)

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
            
        car.position = Vector3(randf_range(-300, 300), 2.0, randf_range(-300, 300))
        add_child(car)

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
            mat.albedo_color = Color(0, 0.2, 1) # Polisi Biru
            m.material_override = mat
            police.add_child(m)
            
            police.position = Vector3(player.position.x + randf_range(-40, 40), 2.0, player.position.z + randf_range(-40, 40))
            add_child(police)
        police_spawned = true

func player_take_damage(amount: float):
    if Global.armor > 0:
        Global.armor -= amount
    else:
        Global.health -= amount
        if Global.health <= 0:
            get_tree().reload_current_scene()
