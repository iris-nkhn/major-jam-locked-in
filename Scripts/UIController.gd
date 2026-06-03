extends Node2D

@onready var heatBar = $Control/HeatBar

func _on_player_heat_change(heat):
	heatBar.value += heat
