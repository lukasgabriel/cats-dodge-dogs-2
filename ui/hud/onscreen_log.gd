extends CodeEdit


var text_frame: String = ""


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	text_frame = ""
	
	var cat = get_parent().get_parent().get_node("Level/Cat")
	var dog = get_parent().get_parent().get_node("Level/Dog")
	
	text_frame += "vCat:\t%.1v\n" % cat.velocity
	text_frame += "pCat:\t%.1v\n" % cat.position
	text_frame += "vDog:\t%.1f\n" % dog.velocity
	text_frame += "pDog:\t%.1v\n" % dog.position
	text_frame += "Hits:\t%s\n" % cat.hit_count
	text_frame += "Win: \t%s\n" % cat.win_state
	
	text = text_frame
