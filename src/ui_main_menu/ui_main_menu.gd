extends Control


func _on_button_play_game_pressed():
	# do thing
	print("Play Game")
	get_tree().change_scene("res://src/game/persistant_world.tscn")
