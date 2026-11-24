extends CharacterBody2D

@export var speed: float = 400.0
var health: float = 100.0
var money: int = 0
var move_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
    velocity = move_direction * speed
    move_and_slide()

func take_damage(amount: float):
    health -= amount
    if health <= 0:
        health = 0
        get_tree().reload_current_scene()

func add_money(amount: int):
    money += amount
