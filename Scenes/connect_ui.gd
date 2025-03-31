extends Control

@onready var ip_ln: LineEdit = $IP_ln
@onready var host_ip: LineEdit = $Host_ip
@onready var name_ln: LineEdit = $name_lbl/Name_ln
@onready var state_lbl: Label = $state_lbl
@onready var start_btn: Button = $Start_btn
@onready var server_browser: Control = $serverBrowser
@onready var room_ip_ln: LineEdit = $room_ip_ln

var port = 1029
var address = IP.get_local_addresses()[IP.get_local_addresses().size()-1]
var is_ready = false
var regex_pattern = RegEx.new()
var avail_ip = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	regex_pattern.compile("(\\w)+")
	Global.total_players_change.connect(server_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(server_disconnected)
	#multiplayer.connection_failed.connect(connection_failed)
	$Start_btn.hide()
	host_ip.text = address

func _process(delta: float) -> void:
	if multiplayer.is_server():
		if multiplayer.get_peers().size()+1 < Global.total_players:
			Global.total_players_change.emit()
	if avail_ip != Global.available_ip:
		room_ip_ln.text = Global.available_ip
		avail_ip = Global.available_ip

func connection_failed():
	Global.peer.close()
	OS.alert("The host's IP is incorrect!")

func _on_host_btn_pressed() -> void:
	server_browser.setUpBroadCast()
	Global.peer.create_server(port, 1)
	multiplayer.multiplayer_peer = Global.peer
	state_lbl.text = "Waiting for client..."
	$Join_btn.hide()

func _on_join_btn_pressed() -> void:
	if ip_ln.text != "":
		Global.peer.create_client(ip_ln.text, port)
		multiplayer.multiplayer_peer = Global.peer
	else:
		OS.alert('You have to input IP!')
		
func server_disconnected():
	Global.total_players -= 1
	state_lbl.modulate = Color.RED
	state_lbl.text = "Disconnected"
	$Host_btn.show()
	$Join_btn.show()
	$Start_btn.hide()
	start_btn.text = "READY!❌"
	start_btn.disabled = false
	is_ready = false
	name_ln.editable = true

func start_game():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	server_browser.cleanUp()

@rpc("any_peer", "call_remote")
func send_enemy_name(ene_name):
	Global.enemy_name = ene_name

func _on_start_btn_pressed() -> void:
	if name_ln.text != "" && regex_pattern.search(name_ln.text).get_string() == name_ln.text:
		start_btn.text = "READY!✅"
		start_btn.disabled = true
		Global.player_name = name_ln.text
		name_ln.editable = false
		rpc("send_enemy_name", name_ln.text)
		check_both_ready.rpc()
	else:
		OS.alert('You have to input name that only contain alphanumeric characters!', 'WARNING')

@rpc("any_peer", "call_local")
func check_both_ready():
	if is_ready == true:
		start_game()
	else:
		is_ready = true

@rpc("any_peer", "call_local")
func connected_notice():
	Global.total_players += 1
	state_lbl.modulate = Color.GREEN
	state_lbl.text = "Conected!"
	$Start_btn.show()
	$Host_btn.hide()

func connected_to_server():
	connected_notice.rpc()

func _on_exit_btn_pressed() -> void:
	if multiplayer.is_server():
		server_browser.send_packet("NONE")
	Global.peer.close()
	Global.online_mode = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
