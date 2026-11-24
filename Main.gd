extends Node3D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthBar
@onready var hud_armor = $UI/ArmorBar
@onready var hud_stamina = $UI/StaminaBar
@onready var hud_wanted = $UI/WantedLabel

var wanted_level: int = 0

func _ready():
    generate_world()
    # Terapkan warna karakter yang dipilih
    var col = Global.char_colors[Global.selected_char]
    player.get_node("MeshRoot/Body").material_override.albedo_color = col

func _process(_delta):
    hud_money.text = "$" + str(Global.money)
    hud_health.value = Global.health
    hud_armor.value = Global.armor
    hud_stamina.value = Global.stamina
    hud_wanted.text = str(wanted_level) + " ★"

func generate_world():
    # 1. Lantai Dasar Raksasa
    var ground = StaticBody3D.new()
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(2000, 2000)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_color = Color(0.15, 0.15, 0.18)
    floor_mesh.material_override = f_mat
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(2000, 1, 2000)
    col.shape = shape
    col.position.y = -0.5
    ground.add_child(floor_mesh)
    ground.add_child(col)
    add_child(ground)

    # 2. ZONA KOTA (X > 0, Z > 0)
    for x in range(1, 8):
        for z in range(1, 8):
            var b = StaticBody3D.new()
            var m = MeshInstance3D.new()
            var b_box = BoxMesh.new()
            var h = randf_range(40, 150)
            b_box.size = Vector3(30, h, 30)
            m.mesh = b_box
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.1, 0.1, 0.2)
            mat.emission_enabled = true
            mat.emission = Color(0.2, 0.4, 0.8) # Jendela biru
            m.material_override = mat
            b.position = Vector3(x * 80, h/2, z * 80)
            b.add_child(m)
            add_child(b)

    # 3. ZONA PANTAI (X < 0, Z > 0)
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

    # 4. ZONA GUNUNG (X < 0, Z < 0)
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

    # 5. ZONA PELABUHAN (X > 0, Z < 0)
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
