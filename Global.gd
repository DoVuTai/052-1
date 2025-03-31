extends Node

signal  total_players_change
var player_name:= "YOU"
var enemy_name:= "BOT"
var total_players = 1
var peer = ENetMultiplayerPeer.new()
var available_ip = ""
var online_mode = false
