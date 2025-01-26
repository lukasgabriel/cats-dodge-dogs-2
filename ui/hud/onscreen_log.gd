extends CodeEdit


var text_frame: String = ""
var tick: int = 0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	text_frame = ""
	tick += 1
	
	var cat = get_parent().get_parent().get_node("Level/Cat")
	var dog = get_parent().get_parent().get_node("Level/Dog")
	
	text_frame += "vCat:\t%03.+v\n" % cat.velocity
	text_frame += "pCat:\t%03.+v\n" % cat.position
	text_frame += "vDog:\t%03.+f\n" % dog.velocity
	text_frame += "pDog:\t%03.+v\n" % dog.position
	text_frame += "Hits:\t%03s\n" % cat.hit_count
	text_frame += "Win: \t%s\n" % cat.win_state
	text_frame += "Tick: \t%s\n" % tick
	
	text = text_frame
