extends Control
@onready var player_r: AnimatedSprite2D = $CanvasLayer/HBoxContainer/player_r
@onready var player_l: AnimatedSprite2D = $CanvasLayer/HBoxContainer/player_l
@onready var enemy_r: AnimatedSprite2D = $CanvasLayer/HBoxContainer2/enemy_r
@onready var enemy_l: AnimatedSprite2D = $CanvasLayer/HBoxContainer2/enemy_l
@onready var question_mark: Label = $questionMark
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

func _ready() -> void:
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
	time += delta * frequency
	floaty(player_l, stop_float[player_l.name])
	floaty(player_r, stop_float[player_r.name])
	floaty(enemy_r, stop_float[enemy_r.name])
	floaty(enemy_l, stop_float[enemy_l.name])
	floaty(question_mark, false)

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
	is_done = false
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
		Engine.time_scale = 0
		pass

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
		rpc("send_hand_state_data", hand_state)
	elif phase == 2:
		rpc("send_hand_remove_data", hand_removed)
	rpc("check_both_done")

@rpc("any_peer", "call_local")#PHASE 1
func show_hand():
	enemy_l.animation = animation_list[enemy_hand_state["l"]]
	enemy_r.animation = animation_list[enemy_hand_state["r"]]
	question_mark.hide()
	phase2()

func phase2():
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
	
	if ((player_hand-enemy_hand)==1) || player_hand-enemy_hand==-2:
		winner = "player"
		impact_lbl.position = question_mark.position
		enemy_lives -= 1
		attack(player_hand_node, enemy_hand_node)
	elif ((player_hand-enemy_hand)==-1) || player_hand-enemy_hand==2 :
		winner = "enemy"
		impact_lbl.position = origin_pos[impact_lbl.name]
		player_lives -= 1
		attack(enemy_hand_node, player_hand_node)
	else:
		next_round()
	update_lives()
	
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
			rpc("show_hand")
			phase += 1
		elif phase == 2:
			ask_remove_lbl.hide()
			show_result()
	else:
		is_done = true

func show_result(): #PHASE 2
	tween = create_tween()
	if enemy_hand_remove[player_l.name] == true:
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
