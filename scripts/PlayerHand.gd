extends Node2D

const HAND_COUNT = 5
const CARD_SCENE_PATH = 'res://scenes/Card.tscn'
const CARD_SIZE = 160
const HAND_Y_MARGIN = 20

var player_hand = []
var center_screen_x
var hand_y_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hand_y_position = get_viewport().size.y - HAND_Y_MARGIN - CARD_SIZE
	
	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		$"../CardManager".add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Helpers

func add_card_to_hand(card):
	player_hand.insert(0, card)
	update_hand_positions()
	
func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		var card = player_hand[i]
		animate_card_to_position(card, new_position)

func calculate_card_position(i):
	var hand_width = (player_hand.size() - 1) * CARD_SIZE
	var card_x_offset = i * CARD_SIZE
	var x_position = card_x_offset + (center_screen_x - hand_width / 2)
	return x_position

func animate_card_to_position(card, position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, 'position', position, 0.1)
