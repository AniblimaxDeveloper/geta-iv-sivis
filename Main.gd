extends Node2D

@onready var player = $Player
@onready var hud_money = $UI/MoneyLabel
@onready var hud_health = $UI/HealthLabel

func _ready():
    generate_city()
    spawn_collectables(40)

func _process(_delta):
    hud_money.text = "CASH: $" + str(player.money)
    hud_health.text = "HEALTH: " + str(int(player.health)) + "%"

# Fungsi untuk menggambar grid jalanan
func _draw():
    var grid_size = 100
    var area_size = 2000
    var line_color = Color(0.15, 0.15, 0.2) # Warna garis abu-abu gelap
    
    for x in range(-area_size, area_size, grid_size):
        draw_line(Vector2(x, -area_size), Vector2(x, area_size), line_color, 2)
    for y in range(-area_size, area_size, grid_size):
        draw_line(Vector2(-area_size, y), Vector2(area_size, y), line_color, 2)

func generate_city():
    for i in range(100):
        var building = StaticBody2D.new()
        var collision = CollisionShape2D.new()
        var rect = RectangleShape2D.new()
        var color_rect = ColorRect.new()
        
        var w = randf_range(100, 300)
        var h = randf_range(100, 300)
        
        rect.size = Vector2(w, h)
        collision.shape = rect
        color_rect.size = Vector2(w, h)
        color_rect.color = Color(0.2, 0.2, 0.25) 
        
        building.position = Vector2(randf_range(-1800, 1800), randf_range(-1800, 1800))
        color_rect.position = -Vector2(w, h) / 2
        collision.position = Vector2.ZERO
        
        building.add_child(color_rect)
        building.add_child(collision)
        add_child(building)

func spawn_collectables(amount: int):
    for i in range(amount):
        var coin = Area2D.new()
        var collision = CollisionShape2D.new()
        var rect = RectangleShape2D.new()
        var sprite = ColorRect.new()
        
        rect.size = Vector2(30, 30)
        collision.shape = rect
        sprite.size = Vector2(30, 30)
        sprite.position = -Vector2(15, 15)
        sprite.color = Color(0.2, 1.0, 0.4)
        
        coin.position = Vector2(randf_range(-1500, 1500), randf_range(-1500, 1500))
        coin.add_child(sprite)
        coin.add_child(collision)
        
        coin.body_entered.connect(_on_coin_collected.bind(coin))
        add_child(coin)

func _on_coin_collected(body, coin):
    if body == player:
        player.add_money(50)
        coin.queue_free()
