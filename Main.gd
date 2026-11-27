extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel
@onready var hud_ammo = $UI/AmmoLabel
@onready var hud_location = $UI/LocationLabel
@onready var radar = $UI/Radar
@onready var sun = $DirectionalLight3D

var time_of_day: float = 0.0
var current_biome: String = "UNKNOWN"

func _ready():
    generate_world_continents()
    
func _process(delta):
    hud_money.text = "$" + str(Global.money)
    hud_health.value = Global.health
    hud_armor.value = Global.armor
    hud_stamina.value = Global.stamina
    hud_ammo.text = "AMMO: 250"
    radar.queue_redraw()
    
    time_of_day += delta * 0.05
    sun.rotation.x = sin(time_of_day) * 1.2
    
    # Deteksi Pemain Ada di Bioma Mana
    var p = player.position
    if p.x > 0 and p.z > 0: current_biome = "KOTA"
    elif p.x < 0 and p.z > 0: current_biome = "GURUN"
    elif p.x < 0 and p.z < 0: current_biome = "SALJU"
    elif p.x > 0 and p.z < 0: current_biome = "PANTAI"
    hud_location.text = "WILAYAH: " + current_biome

func generate_world_continents():
    # 1. Lantai Dasar (Bumi)
    var ground = StaticBody3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(2000, 2000)
    var m = MeshInstance3D.new()
    m.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 0.3, 0.2) # Hijau bumi
    m.material_override = mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(2000, 1, 2000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(m)
    ground.add_child(col)
    add_child(ground)

    # 2. Generate 4 Zona
    for x in range(-10, 10):
        for z in range(-10, 10):
            var pos = Vector3(x * 100, 0, z * 100)
            
            # KOTA (X>0, Z>0)
            if x > 0 and z > 0:
                if randf() > 0.4:
                    var b = StaticBody3D.new()
                    var h = randf_range(40, 150)
                    var box = BoxMesh.new()
                    box.size = Vector3(30, h, 30)
                    var b_m = MeshInstance3D.new()
                    b_m.mesh = box
                    var b_mat = StandardMaterial3D.new()
                    b_mat.albedo_color = Color(0.1, 0.1, 0.15)
                    b_mat.emission_enabled = true
                    b_mat.emission = Color(0.1, 0.4, 0.8)
                    b_m.material_override = b_mat
                    b.position = pos + Vector3(0, h/2, 0)
                    b.add_child(b_m)
                    add_child(b)
            
            # GURUN (X<0, Z>0)
            elif x < 0 and z > 0:
                var sand = MeshInstance3D.new()
                var s_plane = PlaneMesh.new()
                s_plane.size = Vector2(90, 90)
                sand.mesh = s_plane
                var s_mat = StandardMaterial3D.new()
                s_mat.albedo_color = Color(0.8, 0.7, 0.4) # Warna pasir
                sand.material_override = s_mat
                sand.position = pos + Vector3(0, 0.1, 0)
                add_child(sand)
                
            # SALJU (X<0, Z<0)
            elif x < 0 and z < 0:
                var snow = MeshInstance3D.new()
                var sn_plane = PlaneMesh.new()
                sn_plane.size = Vector2(90, 90)
                snow.mesh = sn_plane
                var sn_mat = StandardMaterial3D.new()
                sn_mat.albedo_color = Color(0.9, 0.9, 1.0) # Warna salju
                snow.material_override = sn_mat
                snow.position = pos + Vector3(0, 0.1, 0)
                add_child(snow)
                
                # Pohon Pinus
                if randf() > 0.7:
                    var tree = MeshInstance3D.new()
                    var cyl = CylinderMesh.new()
                    cyl.top_radius = 0.1
                    cyl.bottom_radius = 4.0
                    cyl.height = 15.0
                    tree.mesh = cyl
                    var t_mat = StandardMaterial3D.new()
                    t_mat.albedo_color = Color(0.1, 0.3, 0.1)
                    tree.material_override = t_mat
                    tree.position = pos + Vector3(0, 7.5, 0)
                    add_child(tree)

            # PANTAI (X>0, Z<0)
            elif x > 0 and z < 0:
                var water = MeshInstance3D.new()
                var w_plane = PlaneMesh.new()
                w_plane.size = Vector2(90, 90)
                water.mesh = w_plane
                var w_mat = StandardMaterial3D.new()
                w_mat.albedo_color = Color(0.1, 0.4, 0.9) # Biru air
                w_mat.roughness = 0.1
                water.material_override = w_mat
                water.position = pos + Vector3(0, 0.2, 0)
                add_child(water)
