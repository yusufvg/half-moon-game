extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_SLOT = 2

var screen_size
var card_being_dragged
var is_hovering_on_card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print('yvangieson: checking for card on click')
			var card = raycast_check_for_card()
			if card:
				print('yvangieson: card found')
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag()
				

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)

func finish_drag():
	card_being_dragged.scale = Vector2(1.05, 1.05)
	var slot = raycast_check_for_card_slot()
	if slot and not slot.card_in_slot:
		card_being_dragged.position = slot.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		slot.card_in_slot = true
	
	card_being_dragged = null

func connect_card_signals(card):
	card.connect('hovered', on_hovered_card)
	card.connect('hovered_off', on_hovered_off_card)
	

func on_hovered_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	

func on_hovered_off_card(card):
	highlight_card(card, false)
	
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered: 
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false
	

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		return get_card_with_highest_z_index(result)
	return null

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_SLOT
	var result = space_state.intersect_point(parameters)
	if (result.size() > 0):
		return result[0].collider.get_parent()
	return null

func get_card_with_highest_z_index(cards):
	var top_card = cards[0].collider.get_parent()
	var top_index = top_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > top_index:
			top_card = current_card
			top_index = top_card.z_index
	
	return top_card
