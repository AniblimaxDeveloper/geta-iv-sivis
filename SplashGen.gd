extends Node3D
func _ready():
    # Generate Gedung
    for i in range(30):
        var b = MeshInstance3D.new()
        var box = BoxMesh.new()
        box.size = Vector3(randf_range(10,20), randf_range(40,100), randf_range(10,20))
        b.mesh = box
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.1, 0.1, 0.2)
        mat.emission_enabled = true
        mat.emission = Color(0, 0.5, 1)
        b.material_override = mat
        b.position = Vector3(randf_range(-50,50), box.size.y/2, randf_range(-50,50))
        add_child(b)
