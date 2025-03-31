extends Node

var broadcastTimer : Timer

var broadcaster : PacketPeerUDP
var listner : PacketPeerUDP
var listenPort : int = 1034
var broadcastPort : int = 1032
var broadcastAddress : String = "255.255.255.255"
var hostip = IP.get_local_addresses()[IP.get_local_addresses().size()-1]
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	setUp()
	
func setUp():
	listner = PacketPeerUDP.new()
	listner.bind(listenPort)
		
func setUpBroadCast():
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	broadcaster.bind(broadcastPort)
	#timer.start()
	send_packet(hostip)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if listner.get_available_packet_count() > 0:
		Global.available_ip = listner.get_packet().get_string_from_ascii()

func cleanUp():
	listner.close()
	if broadcaster != null:
		broadcaster.close()

func _exit_tree() -> void:
	cleanUp()

func send_packet(pack):
	var packet = pack
	var data = packet.to_ascii_buffer()
	if broadcaster != null:
		broadcaster.put_packet(data)

#func _on_timer_timeout() -> void:
	#send_packet(hostip)
