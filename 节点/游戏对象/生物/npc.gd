extends RigidBody3D

@export var httpRequest: HTTPRequest
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func operate_object(operateString: String):
	print("##回答##"+operateString)
	

func try_operate() -> void:
	var area = $Area3D # 获取Area3D节点
	var bodies = area.get_overlapping_bodies() # 获取碰撞物体列表
	if bodies:
		var content = "你是游戏npc，名为"+self.name+"，下面是你周围的可交互对象:\n我给出的操作的格式为：\n[可交互对象名称]\n操作名称1(参数1:参数1类型， 参数2:参数2类型 ...)\n操作名称2(参数1:参数1类型， 参数2:参数2类型 ...)\n"
		for body in bodies:
			if not "operatable_dict" in body: continue
			content += "[" + body.name + "]\n"
			for operatable in body.operatable_dict.keys():
				content += operatable + '\n'
		content += "替换方括号里的内容，你回答的格式如下:\n[想要操作对象].[操作名称]([要传入的参数1], [要传入的参数2], [...])\n因为我会直接使用eval运行你的话，所以要严格遵守格式，除了这行字以外不要发送任何文字"
		print("#############发送消息#############\n"+content)	
		httpRequest.requestAI(content, operate_object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= 5.0:
		try_operate()
		timer = 0.0
		
	
