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
    spawn_traffic(15)
    spawn_peds(20)

func _process(delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_stamina.value = player.stamina
    hud_wanted.text = str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)
    radar.queue_redraw()
    
    time_of_day += delta * 0.02
    sun.rotation.x = sin(time_of_day) * 1.2

func generate_world():
    # 1. Lantai Aspal Abu-abu
    var ground = StaticBody3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(1000, 1000)
    var m = MeshInstance3D.new()
    m.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 0.2, 0.22) # Warna aspal terang
    m.material_override = mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1000, 1, 1000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(m)
    ground.add_child(col)
    add_child(ground)

    # 2. Gedung-gedung (Grid di sekitar pemain)
    for x in range(-4, 5):
        for z in range(-4, 5):
            if x == 0 and z == 0: continue # Biarkan titik spawn kosong
            
            var b = StaticBody3D.new()
            var h = randf_range(40, 150)
            var box = BoxMesh.new()
            box.size = Vector3(30, h, 30)
            var b_m = MeshInstance3D.new()
            b_m.mesh = box
            var b_mat = StandardMaterial3D.new()
            b_mat.albedo_color = Color(0.1, 0.1, 0.15)
            b_mat.emission_enabled = true
            b_mat.emission = Color(0.2, 0.4, 0.8) # Jendela biru
            b_m.material_override = b_mat
            
            var c = CollisionShape3D.new()
            var s = BoxShape3D.new()
            s.size = box.size
            c.shape = s
            
            b.position = Vector3(x * 60, h/2, z * 60)
            b.add_child(b_m)
            b.add_child(c)
            add_child(b)

    # 3. Lampu Jalan
    for i in range(15):
        var light = OmniLight3D.new()
        light.light_color = Color(1, 0.8, 0.4)
        light.light_energy = 3.0
        light.omni_range = 20.0
        light.position = Vector3(randf_range(-200, 200), 8, randf_range(-200, 200))
        add_child(light)
