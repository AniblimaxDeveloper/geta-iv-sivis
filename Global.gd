extends Node
var player_name: String = "Jason_Duval"
var selected_char: int = 0
var money: int = 250000
var health: float = 100.0
var armor: float = 50.0
var stamina: float = 100.0

# Daftar lokasi Fast Travel
var locations = {
    "KOTA METROPOLITAN": Vector3(500, 5, 500),
    "GURUN PASIR": Vector3(-500, 5, 500),
    "HUTAN SALJU": Vector3(-500, 5, -500),
    "PANTAI TROPIS": Vector3(500, 5, -500)
}
