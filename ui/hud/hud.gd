extends CanvasLayer


func _ready() -> void:
	if !get_parent().debug:
		remove_child($OnscreenLog)


func _process(delta: float) -> void:
	pass
