extends CharacterBody3D

@export var walk_speed: float = 10.0
@export var run_speed: float = 22.0
@export var jump_force: float = 14.0
@export var gravity: float = 35.0

var health: float = 100.0
var armor: float = 50.0
var stamina: float = 100.0
var ammo: int = 250
var money: int = 50000
var input_dir: Vector2 = Vector2.ZERO
var is_running: bool = false
var current_vehicle: VehicleBody3D = null
var walk_time: float = 0.0

@onready var mesh_root = $MeshRoot
@onready var left_leg = $MeshRoot/LeftLeg
@onready var right_leg = $MeshRoot/RightLeg
@onready var left_arm = $MeshRoot/LeftArm
@onready var right_arm = $MeshRoot/RightArm
@onready var weapon = $MeshRoot/RightArm/Weapon
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
@onready var muzzle_flash = $MuzzleFlash

func _ready():
    # SIHIR: Cek file .glb, lalu .obj
    if ResourceLoader.exists("res://Player.glb"):
        var model = load("res://Player.glb").instantiate()
        mesh_root.add_child(model)
        _hide_procedural()
        print("Muat Model GLB Sukses!")
    elif ResourceLoader.exists("res://Player.obj"):
        var model = load("res://Player.obj").instantiate()
        mesh_root.add_child(model)
        _hide_procedural()
        print("Muat Model OBJ Sukses!")

func _hide_procedural():
    $MeshRoot/Body.visible = false
    $MeshRoot/Head.visible = false
    $MeshRoot/LeftArm.visible = false
    $MeshRoot/RightArm.visible = false
    $MeshRoot/LeftLeg.visible = false
    $MeshRoot/RightLeg.visible = false

# (Sisa kode physics_process, jump, shoot, interact, take_damage sama seperti sebelumnya)
# Agar tidak kepanjangan, saya pastikan Bos copy script Player.gd Phase 24 yang tadi,
# lalu timpa bagian _ready() saja dengan yang di atas.
