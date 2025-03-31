extends Control
@onready var player_r: AnimatedSprite2D = $CanvasLayer/HBoxContainer/player_r
@onready var player_l: AnimatedSprite2D = $CanvasLayer/HBoxContainer/player_l
@onready var enemy_r: AnimatedSprite2D = $CanvasLayer/HBoxContainer2/enemy_r
@onready var enemy_l: AnimatedSprite2D = $CanvasLayer/HBoxContainer2/enemy_l
@onready var question_mark: Label = $CanvasLayer/questionMark
@onready var done_btn: Button = $done_btn
@onready var switch_l_btn: Button = $switch_l_btn
@onready var switch_r_btn: Button = $switch_r_btn
@onready var enemy_name_lbl: Label = $Enemy_name_lbl
@onready var player_name_lbl: Label = $Player_name_lbl
@onready var ask_remove_lbl: Label = $ask_remove_lbl
@onready var enemy_lives_lbl: Label = $enemy_lives_lbl
@onready var player_lives_lbl: Label = $player_lives_lbl
@onready var camera_2d: Camera2D = $Camera2D
@onready var impact_lbl: Label = $CanvasLayer/impact_lbl
@onready var color_rect: ColorRect = $ColorRect
@onready var end_game_scene: CanvasLayer = $end_game_layer
@onready var winner_lbl: Label = $end_game_layer/winner_lbl
@onready var rematch_btn: Button = $end_game_layer/rematch_btn

var amplitude = 1.0
var frequency = 2.0
var time = 0
var default_pos = {}
var origin_pos = {}
var animation_list = ["rock", "paper", "scissor"]
var animation_index = {"l": 0, "r": 0}
var hand_state = {"l": 0, "r": 0}
var hand_state_phase2 = {"l": 0, "r": 0}
var enemy_hand_state = {"l": 0, "r": 0}
var enemy_hand_remove = {}
var is_done = false
var is_rematch = false
var phase = 1
var stop_float = {}
var hand_removed = {}
var tween
var player_lives = 5
var enemy_lives = 5
var enemy_hand
var player_hand
var enemy_hand_node:Node
var player_hand_node:Node
var winner = ""
var pause = false
var end = false
var rng = RandomNumberGenerator.new()
var enemy_chance = 0

func _ready() -> void:
	if Global.online_mode:
		Global.total_players_change.connect(server_disconnected)
		multiplayer.server_disconnected.connect(server_disconnected)
	else : rng.randomize()
	end_game_scene.hide()
	update_lives()
	default_pos = {player_l.name: player_l.position, 
				player_r.name: player_r.position,
				enemy_r.name: enemy_r.position,
				enemy_l.name: enemy_l.position,
				question_mark.name: question_mark.position,
				impact_lbl.name: impact_lbl.position}
	origin_pos = default_pos.duplicate(true)
	stop_float = {player_l.name: false, player_r.name: false, enemy_l.name: false, enemy_r.name: false}
	hand_removed = {player_l.name: false, player_r.name: false}
	enemy_hand_remove = {player_l.name: false, player_r.name: false}
	ask_remove_lbl.hide()
	impact_lbl.hide()
	player_name_lbl.text = Global.player_name
	enemy_name_lbl.text = Global.enemy_name

func _process(delta: float) -> void:
	if Global.online_mode:
		if multiplayer.is_server() && multiplayer.get_peers().size()+1 < Global.total_players:
			Global.total_players_change.emit()
	time += delta * frequency
	floaty(player_l, stop_float[player_l.name])
	floaty(player_r, stop_float[player_r.name])
	floaty(enemy_r, stop_float[enemy_r.name])
	floaty(enemy_l, stop_float[enemy_l.name])
	floaty(question_mark, false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") && end==false:
		pause = !pause
		if pause == true:
			show_pause_menu()
		else :
			hide_pause_menu()
	
func hide_pause_menu():
	Engine.time_scale = 1
	end_game_scene.hide()
	rematch_btn.text = "REMATCH❌"
	rematch_btn.disabled = false
	is_rematch = false

func server_disconnected():
	Global.total_players -= 1
	question_mark.text = "Disconnected!"
	question_mark.show()

func next_round():
	enemy_l.animation = "unknown"
	enemy_r.animation = "unknown"
	question_mark.show()
	done_btn.text = "DONE❌"
	done_btn.disabled = false
	switch_l_btn.show()
	switch_r_btn.show()
	switch_l_btn.disabled = false
	switch_r_btn.disabled = false
	switch_l_btn.text = "◀️"
	switch_r_btn.text = "▶️"
	
	default_pos = origin_pos.duplicate(true)
	animation_index = {"l": 0, "r": 0}
	player_l.animation = animation_list[animation_index["l"]]
	player_r.animation = animation_list[animation_index["r"]]
	hand_state = {"l": 0, "r": 0}
	hand_state_phase2 = {"l": 0, "r": 0}
	enemy_hand_state = {"l": 0, "r": 0}
	enemy_hand_remove = {player_l.name: false, player_r.name: false}
	enemy_chance = 0
	is_done = false
	is_rematch = false
	end = false
	phase = 1
	stop_float = {player_l.name: false, player_r.name: false, enemy_l.name: false, enemy_r.name: false}
	hand_removed = {player_l.name: false, player_r.name: false}
	
func floaty(object: Node, allow_float):
	if allow_float == false:
		object.set_position(default_pos[object.name] + Vector2(0, sin(time) * amplitude))

func update_lives():
	player_lives_lbl.text = ""
	for i in player_lives:
		player_lives_lbl.text += "❤️"
		
	enemy_lives_lbl.text = ""
	for i in enemy_lives:
		enemy_lives_lbl.text += "❤️"
		
	if enemy_lives == 0:
		end = !end
		update_winner(Global.player_name)
		show_pause_menu()
	elif  player_lives == 0:
		end = !end
		update_winner(Global.enemy_name)
		show_pause_menu()

func show_pause_menu():
	Engine.time_scale = 0
	end_game_scene.show()

func _on_switch_l_btn_pressed() -> void:
	if phase == 1:
		animation_index["l"] +=1
		if animation_index["l"] == 3:
			animation_index["l"]=0
		player_l.animation = animation_list[animation_index["l"]]
	elif phase == 2:
		hand_state_phase2["l"] = -1
		hand_state_phase2["r"] = hand_state["r"]
		ask_remove_lbl.text = "Left hand removed!"
		done_btn.disabled = false
		remove_hand(player_l)
		switch_l_btn.disabled = true
		switch_r_btn.disabled = false
		if hand_removed[player_r.name] == true:
			hand_out(player_r)
		
func hand_out(hand: Node):
	stop_float[hand.name] = true
	tween = create_tween()
	tween.tween_property(hand, "position:y", origin_pos[hand.name].y, 0.2)
	await tween.finished
	default_pos[hand.name] -= Vector2(0, 150)
	stop_float[hand.name] = false
	hand_removed[hand.name] = false
	
func remove_hand(hand: Node):
	stop_float[hand.name] = true
	tween = create_tween()
	tween.tween_property(hand, "position", Vector2(0, 150), 0.2)
	await tween.finished
	default_pos[hand.name] += Vector2(0, 150)
	stop_float[hand.name] = false
	hand_removed[hand.name] = true
	
func _on_switch_r_btn_pressed() -> void:
	if phase == 1:
		animation_index["r"] +=1
		if animation_index["r"] == 3:
			animation_index["r"]=0
		player_r.animation = animation_list[animation_index["r"]]
	elif phase == 2:
		hand_state_phase2["r"] = -1
		hand_state_phase2["l"] = hand_state["l"]
		ask_remove_lbl.text = "Right hand removed!"
		done_btn.disabled = false
		remove_hand(player_r)
		switch_l_btn.disabled = false
		switch_r_btn.disabled = true
		if hand_removed[player_l.name] == true:
			hand_out(player_l)

func _on_done_btn_pressed() -> void:
	done_btn.text = "DONE✅"
	done_btn.disabled = true
	switch_l_btn.hide()
	switch_r_btn.hide()
	if phase == 1:
		hand_state = {"l": animation_index["l"], "r": animation_index["r"]}
		hand_state_phase2 = hand_state.duplicate()
		if Global.online_mode: rpc("send_hand_state_data", hand_state)
		else:
			enemy_hand_state["l"] = rng.randi_range(0, 2)
			enemy_hand_state["r"] = rng.randi_range(0, 2)
			while enemy_hand_state["r"] == enemy_hand_state["l"]:
				enemy_hand_state["r"] = rng.randi_range(0, 2)
			show_hand()
	elif phase == 2:
		if Global.online_mode: rpc("send_hand_remove_data", hand_removed)
		else:
			for ekey in enemy_hand_state:
				for pkey in hand_state:
					if calc_win(enemy_hand_state[ekey], hand_state[pkey]) == enemy_hand_state[ekey]:
						if ekey == "r": 
							enemy_chance -= 1
						else: 
							enemy_chance += 1
			if enemy_chance < 0: enemy_hand_remove[player_l.name] = true
			elif enemy_chance > 0: enemy_hand_remove[player_l.name] = false
			else: enemy_hand_remove[player_l.name] = bool(rng.randi_range(0, 1))
			enemy_hand_remove[player_r.name] = !enemy_hand_remove[player_l.name]
			print(enemy_chance)
			show_result()
	if Global.online_mode: rpc("check_both_done")

@rpc("any_peer", "call_local")#PHASE 1
func show_hand():
	enemy_l.animation = animation_list[enemy_hand_state["l"]]
	enemy_r.animation = animation_list[enemy_hand_state["r"]]
	question_mark.hide()
	phase2()

func phase2():
	phase += 1
	done_btn.text = "DONE❌"
	switch_l_btn.text = "❌"
	switch_r_btn.text = "❌"
	switch_l_btn.show()
	switch_r_btn.show()
	ask_remove_lbl.show()
	is_done = false

func calc_result():#PHASE 2
	if enemy_hand_state["l"] == -1:
		enemy_hand = enemy_hand_state["r"]
		enemy_hand_node = enemy_r
	else :
		enemy_hand = enemy_hand_state["l"]
		enemy_hand_node = enemy_l
	
	if hand_state_phase2["l"] == -1:
		player_hand = hand_state_phase2["r"]
		player_hand_node = player_r
	else:
		player_hand = hand_state_phase2["l"]
		player_hand_node = player_l
	
	if calc_win(player_hand, enemy_hand) == player_hand:
		winner = "player"
		impact_lbl.position = question_mark.position
		enemy_lives -= 1
		await attack(player_hand_node, enemy_hand_node)
	elif calc_win(player_hand, enemy_hand) == enemy_hand :
		winner = "enemy"
		impact_lbl.position = origin_pos[impact_lbl.name]
		player_lives -= 1
		await attack(enemy_hand_node, player_hand_node)
	else:
		next_round()
	update_lives()
	
func calc_win(ur_hand, bot_hand):
	if ((ur_hand-bot_hand)==1) || ur_hand-bot_hand==-2:
		return ur_hand
	elif ((ur_hand-bot_hand)==-1) || ur_hand-bot_hand==2 :
		return bot_hand
	else : return -1
	
func attack(hand_win:Node, hand_lost:Node):#PHASE 2
	stop_float[hand_win.name] = true
	tween = create_tween()
	if winner == "player":
		tween.tween_property(hand_win, "position", Vector2(0, -250), 0.2)
		impact_lbl.show()
		camera_2d.apply_shake(hand_lost)
		tween.tween_property(hand_win, "position", default_pos[hand_win.name], 0.2)
	else :
		tween.tween_property(hand_win, "position", Vector2(0, 250), 0.2)
		impact_lbl.show()
		camera_2d.apply_shake(hand_lost)
		tween.tween_property(hand_win, "position", default_pos[hand_win.name], 0.2)
	await tween.finished
	impact_lbl.hide()
	stop_float[hand_win.name] = false
	$Timer.start()
	await $Timer.timeout
	next_round()
	
@rpc("any_peer", "call_local")
func check_both_done():
	if is_done == true:
		if phase == 1:
			#phase += 1
			rpc("show_hand")
		elif phase == 2:
			ask_remove_lbl.hide()
			show_result()
	else:
		is_done = true

func show_result(): #PHASE 2
	tween = create_tween()
	if enemy_hand_remove[player_l.name]:
		tween.tween_property(enemy_l, "position:y", -150, 0.2)
		await tween.finished
		default_pos[enemy_l.name] -= Vector2(0, 150)
		enemy_hand_state["l"] = -1
	else:
		tween.tween_property(enemy_r, "position:y", -150, 0.2)
		await tween.finished
		default_pos[enemy_r.name] -= Vector2(0, 150)
		enemy_hand_state["r"] = -1
	$Timer.start()
	await $Timer.timeout
	calc_result()

@rpc("any_peer", "call_remote")#PHASE 1
func send_hand_state_data(hand_state_data):
	enemy_hand_state = hand_state_data

@rpc("any_peer", "call_remote")#PHASE 2
func send_hand_remove_data(hand_remove_data):
	enemy_hand_remove = hand_remove_data

func update_winner(name):
	winner_lbl.text = name + " WIN!"
	winner_lbl.uppercase = true

func _on_rematch_btn_pressed() -> void:
	if Global.online_mode:
		rematch_btn.text = "REMATCH✅"
		rematch_btn.disabled = true
		check_both_rematch.rpc()
	else: rematch()

@rpc("any_peer", "call_local")
func rematch():
	hide_pause_menu()
	next_round()
	enemy_lives = 5
	player_lives = 5
	update_lives()

func _on_lobby_btn_pressed() -> void:
	if Global.online_mode:
		get_tree().change_scene_to_file("res://Scenes/connect_ui.tscn")
		Global.peer.close()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	Engine.time_scale = 1

@rpc("any_peer", "call_local")
func check_both_rematch():
	if is_rematch == true:
		rematch.rpc()
	else:
		is_rematch = true
