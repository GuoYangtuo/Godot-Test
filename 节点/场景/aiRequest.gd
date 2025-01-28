extends HTTPRequest

func requestAI(content: String, callback: Callable) -> void:
	var url = "https://spark-api-open.xf-yun.com/v1/chat/completions"
	var body := {
	"messages": [
		{
			"role": "user",
			"content": content
		}
	],
	"model": "4.0Ultra"
}
	
	var headers := ['Authorization: Bearer xJmfFnXWmPqhFqwFdcfu:bJXlfUzleHIpHdfgxqMe']
	request(url, headers, HTTPClient.METHOD_POST, JSON.new().stringify(body))
	self.request_completed.connect(_on_request_completed.bind(callback))

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	var json := JSON.new()
	var data = json.parse_string(body.get_string_from_utf8())
	callback.call(data["choices"][0]["message"]["content"])
