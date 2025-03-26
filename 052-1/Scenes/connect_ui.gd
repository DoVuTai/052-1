extends Control

@onready var ip_ln: LineEdit = $IP_ln
@onready var host_ip: LineEdit = $Host_ip
@onready var name_ln: LineEdit = $name_lbl/Name_ln
@onready var state_lbl: Label = $state_lbl
@onready var start_btn: Button = $Start_btn

var peer = ENetMultiplayerPeer.new()
var port = 1029
var address = IP.get_local_addresses()
var total_players = 0
var is_ready = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(server_disconnected)
	$Start_btn.hide()
	host_ip.text = address[IP.get_local_addresses().size()-1]

func _on_host_btn_pressed() -> void:
	if name_ln.text != "":
		peer.create_server(port, 1)
		multiplayer.multiplayer_peer = peer
		state_lbl.text = "Waiting for client..."
		$Join_btn.hide()
	else:
		OS.alert('You have to input name!', 'WARNING')

func _on_join_btn_pressed() -> void:
	if name_ln.text != "" && ip_ln.text != "":
		peer.create_client(ip_ln.text, port)
		multiplayer.multiplayer_peer = peer
		$Host_btn.hide()
	else:
		OS.alert('You have to input name and IP!', 'WARNING')

func server_disconnected():
	print("Disconnected")
	state_lbl.modulate = Color.RED
	state_lbl.text = "Server disconnected!"
	$Host_btn.show()
	$Start_btn.hide()

func start_game():
	var scene = load("res://Scenes/game.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

@rpc("any_peer", "call_remote")
func send_enemy_name(ene_name):
	Global.enemy_name = ene_name

func _on_start_btn_pressed() -> void:
	start_btn.text = "READY!✅"
	start_btn.disabled = true
	Global.player_name = name_ln.text
	name_ln.editable = false
	rpc("send_enemy_name", name_ln.text)
	check_both_ready.rpc()

@rpc("any_peer", "call_local")
func check_both_ready():
	if is_ready == true:
		start_game()
	else:
		is_ready = true

@rpc("any_peer", "call_local")
func connected_notice():
	state_lbl.modulate = Color.GREEN
	state_lbl.text = "Conected!"
	$Start_btn.show()

func connected_to_server():
	connected_notice.rpc()
