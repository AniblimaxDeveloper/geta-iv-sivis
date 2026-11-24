extends Node

var selected_char: int = 0
var money: int = 250000
var health: float = 100.0
var armor: float = 100.0
var stamina: float = 100.0

# 10 Warna Baju untuk 10 Karakter
var char_colors = [
    Color(1, 0, 0),       # Merah
    Color(0, 1, 0),       # Hijau
    Color(0, 0, 1),       # Biru
    Color(1, 1, 0),       # Kuning
    Color(1, 0, 1),       # Ungu
    Color(0, 1, 1),       # Cyan
    Color(1, 0.5, 0),     # Oranye
    Color(0.5, 0, 1),     # Violet
    Color(1, 1, 1),       # Putih
    Color(0.2, 0.2, 0.2)  # Hitam
]
