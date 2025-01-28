extends RigidBody3D

@export var httpRequest: HTTPRequest
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
var identify = "你是一个充满爱的女孩"

func operate_object(operateString: String, bodies: Array[Node3D]):
	print("##回答##\n"+operateString)
	var parts = operateString.split("|")
	for body in bodies:
		if body.name == parts[0]:
			body.call(parts[1], parts[2].split(','))

func try_operate() -> void:
	var area = $Area3D # 获取Area3D节点
	var bodies = area.get_overlapping_bodies() # 获取碰撞物体列表
	if bodies:
		var content = "你是游戏npc，名为"+self.name+","+identify+"，下面是你周围的可交互对象:\n我给出操作的格式为：\n[可交互对象名称]\n对象属性以及可操作的方法\n"
		for body in bodies:
			if not "operate_code" in body: continue
			content += "[" + body.name + "]"
			content += body.operate_code + '\n'
		content += "请你挑选一个对象进行一次交互，你回答的格式如下:\n想要操作对象|操作方法名称|参数1,参数2,参数3...\n如果传入的参数是字符串，不需要加英文双引号，如果是整数或浮点，也用数字，要严格遵守格式，除了这行字以外不要发送任何文字"
		print("#############发送消息#############\n"+content)	
		httpRequest.requestAI(content, func(operateString: String):operate_object(operateString, bodies))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= 5.0:
		try_operate()
		timer = 0.0
		
	
