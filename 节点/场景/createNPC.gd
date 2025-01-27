extends Node

var npcOBJ: PackedScene
@export var httpRequest: HTTPRequest

func createNPC(nameList: String):
	var names = nameList.split("\n")
	for name in names:
		var npc = npcOBJ.instantiate()
		npc.name = name.split(".")[1].strip_edges()
		add_child(npc)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	httpRequest.requestAI(
		"生成五个英文名， 除此之外不要发送其它文本", createNPC)
	npcOBJ = preload("res://节点/游戏对象/生物/npc.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
