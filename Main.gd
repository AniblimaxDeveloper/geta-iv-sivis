extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var radar = $UI/Radar
@onready var sun = $DirectionalLight3D

var wanted_level: int = 0
var police_spawned: bool = false
var time_of_day: float = 0.0

func _ready():
    generate_massive_map()
    spawn_traffic(20)
    spawn_peds(30)

func _process(delta):
    hud_money.text = "$" + str(player.money)
    hud_health.value = player.health
    hud_armor.value = player.armor
    hud_stamina.value = player.stamina
    hud_wanted.text = str(wanted_level) + " ★"
    hud_ammo.text = "AMMO: " + str(player.ammo)
    radar.queue_redraw()
    
    # Siklus Siang Malam
    time_of_day += delta * 0.05
    sun.rotation.x = sin(time_of_day) * 1.2
    sun.light_energy = abs(sin(time_of_day)) * 2.0 + 0.5 # Redup saat malam

func generate_massive_map():
    # 1. Lantai Dasar (Aspal/Tanah)
    var ground = StaticBody3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(2000, 2000)
    var m = MeshInstance3D.new()
    m.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.15, 0.15, 0.18)
    m.material_override = mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(2000, 1, 2000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(m)
    ground.add_child(col)
    add_child(ground)

    # 2. Generate 4 Wilayah
    for x in range(-10, 10):
        for z in range(-10, 10):
            var pos = Vector3(x * 80, 0, z * 80)
            
            if x > 0 and z > 0:
                # ZONA KOTA (Gedung Pencakar Langit)
                var b = StaticBody3D.new()
                var h = randf_range(50, 180)
                var box = BoxMesh.new()
                box.size = Vector3(40, h, 40)
                var b_m = MeshInstance3D.new()
                b_m.mesh = box
                var b_mat = StandardMaterial3D.new()
                b_mat.albedo_color = Color(0.1, 0.1, 0.15)
                b_mat.emission_enabled = true
                b_mat.emission = Color(0.1, 0.4, 0.8) # Jendela biru
                b_m.material_override = b_mat
                var c = CollisionShape3D.new()
                var s = BoxShape3D.new()
                s.size = box.size
                c.shape = s
                b.position = pos + Vector3(0, h/2, 0)
                b.add_child(b_m)
                b.add_child(c)
                add_child(b)
                
            elif x < 0 and z > 0:
                # ZONA PANTAI (Air Biru)
                if randf() > 0.7:
                    var water = MeshInstance3D.new()
                    var w_plane = PlaneMesh.new()
                    w_plane.size = Vector2(70, 70)
                    water.mesh = w_plane
                    var w_mat = StandardMaterial3D.new()
                    w_mat.albedo_color = Color(0.1, 0.4, 0.9)
                    w_mat.roughness = 0.1
                    water.material_override = w_mat
                    water.position = pos + Vector3(0, 0.1, 0)
                    add_child(water)
                    
            elif x < 0 and z < 0:
                # ZONA PEGUNUNGAN (Kerucut Tinggi)
                var mount = MeshInstance3D.new()
                var cyl = CylinderMesh.new()
                cyl.top_radius = 0.5
                cyl.bottom_radius = randf_range(30, 50)
                cyl.height = randf_range(80, 200)
                mount.mesh = cyl
                var m_mat = StandardMaterial3D.new()
                m_mat.albedo_color = Color(0.2, 0.3, 0.2) # Hijau Gelap
                mount.material_override = m_mat
                mount.position = pos + Vector3(0, cyl.height/2, 0)
                add_child(mount)
                
            elif x > 0 and z < 0:
                # ZONA PEDESAAN (Pohon)
                if randf() > 0.5:
                    var tree = Node3D.new()
                    var trunk = MeshInstance3D.new()
                    var cyl = CylinderMesh.new()
                    cyl.height = 10.0
                    trunk.mesh = cyl
                    trunk.position.y = 5.0
                    var t_mat = StandardMaterial3D.new()
                    t_mat.albedo_color = Color(0.3, 0.15, 0.05)
                    trunk.material_override = t_mat
                    tree.add_child(trunk)
                    
                    var leaves = MeshInstance3D.new()
                    var sph = SphereMesh.new()
                    sph.radius = 5.0
                    leaves.mesh = sph
                    leaves.position.y = 12.0
                    var l_mat = StandardMaterial3D.new()
                    l_mat.albedo_color = Color(0.1, 0.5, 0.1)
                    leaves.material_override = l_mat
                    tree.add_child(leaves)
                    
                    tree.position = pos
                    add_child(tree)
                    
    # Lampu Jalan Kota
    for i in range(30):
        var light = OmniLight3D.new()
        light.light_color = Color(1, 0.8, 0.4)
        light.light_energy = 5.0
        light.omni_range = 40.0
        light.position = Vector3(randf_range(0, 800), 15, randf_range(0, 800))
        add_child(light)

# (Fungsi spawn_traffic, spawn_peds, panic_pedestrians, add_wanted_level SAMA SEPERTI SEBELUMNYA)
# Salin dari Phase 24 / kode sebelumnya
