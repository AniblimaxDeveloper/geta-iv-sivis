extends CanvasLayer

@onready var joystick_base = $JoystickBase
@onready var joystick_knob = $JoystickBase/JoystickKnob
@onready var player = get_node("../Player")

var touch_index = -1
var look_index = -1
var base_center = Vector2.ZERO
var max_distance = 100.0

func _ready():
    joystick_base.visible = false
    joystick_knob.visible = false

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < 600 and touch_index == -1:
            touch_index = event.index
            base_center = event.position
            joystick_base.global_position = base_center - joystick_base.size / 2
            joystick_knob.global_position = base_center - joystick_knob.size / 2
            joystick_base.visible = true
            joystick_knob.visible = true
        elif not event.pressed and event.index == touch_index:
            touch_index = -1
            joystick_base.visible = false
            joystick_knob.visible = false
            player.input_dir = Vector2.ZERO
            
        if event.pressed and event.position.x >= 600:
            look_index = event.index
        elif not event.pressed and event.index == look_index:
            look_index = -1

    if event is InputEventScreenDrag:
        if event.index == touch_index:
            var diff = event.position - base_center
            if diff.length() > max_distance: diff = diff.normalized() * max_distance
            joystick_knob.global_position = base_center + diff - joystick_knob.size / 2
            player.input_dir = diff / max_distance
        elif event.index == look_index:
            player.camera_pivot.rotate_y(-event.relative.x * 0.01)

func _on_jump_button_pressed(): player.jump()
