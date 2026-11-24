extends Node2D
@export var speed: float = 320.0
@onready var player: CharacterBody2D = $Player
@onready var ui_label: Label = $UI/Label

func _ready() -> void:
_add_key_action("move_left",  KEY_A)
_add_key_action("move_right", KEY_D)
_add_key_action("move_up",    KEY_W)
_add_key_action("move_down",  KEY_S)
_add_key_action("move_left",  KEY_LEFT)
_add_key_action("move_right", KEY_RIGHT)
_add_key_action("move_up",    KEY_UP)
_add_key_action("move_down",  KEY_DOWN)

func _add_key_action(action: StringName, keycode: Key) -> void:
if not InputMap.has_action(action):
InputMap.add_action(action)
var ev := InputEventKey.new()
ev.physical_keycode = keycode
InputMap.action_add_event(action, ev)

func _physics_process(_delta: float) -> void:
var direction := Vector2.ZERO
direction.x = Input.get_axis("move_left", "move_right")
direction.y = Input.get_axis("move_up", "move_down")
if direction.length() > 1.0:
direction = direction.normalized()
player.velocity = direction * speed
player.move_and_slide()
ui_label.text = "GETA IV SIVIS\nPos: (%.0f, %.0f)" % [player.position.x, player.position.y]
