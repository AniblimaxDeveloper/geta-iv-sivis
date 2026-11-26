extends CanvasLayer
@onready var j_base = $JoystickBase
@onready var j_knob = $JoystickBase/JoystickKnob
@onready var player = get_node("../Player")
var touch_idx = -1
var look_idx = -1
var center = Vector2.ZERO

func _ready():
    j_base.visible = false
    j_knob.visible = false

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < 600 and touch_idx == -1:
            touch_idx = event.index
            center = event.position
            j_base.global_position = center - j_base.size / 2
            j_knob.global_position = center - j_knob.size / 2
            j_base.visible = true
            j_knob.visible = true
        elif not event.pressed and event.index == touch_idx:
            touch_idx = -1
            j_base.visible = false
            j_knob.visible = false
            player.input_dir = Vector2.ZERO
            
        if event.pressed and event.position.x >= 600:
            look_idx = event.index
        elif not event.pressed and event.index == look_idx:
            look_idx = -1

    if event is InputEventScreenDrag:
        if event.index == touch_idx:
            var diff = event.position - center
            if diff.length() > 100: diff = diff.normalized() * 100
            j_knob.global_position = center + diff - j_knob.size / 2
            player.input_dir = diff / 100
        elif event.index == look_idx:
            player.camera_pivot.rotate_y(-event.relative.x * 0.01)
            player.camera_pivot.get_node("SpringArm3D").rotate_x(-event.relative.y * 0.01)

func _on_jump_btn_pressed(): player.jump()
func _on_shoot_btn_pressed(): player.shoot()
func _on_car_btn_pressed(): player.interact()
func _on_weapon_btn_pressed(): player.toggle_weapon()
