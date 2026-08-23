extends Node
# 《末命》全局事件总线（自动加载）
# 用于解耦：世界 <-> UI <-> 系统。

signal interact_prompt(text: String)
signal interact_hide()
signal open_issue(data: Dictionary)
signal meishan_begin()
signal first_sow()   # M1A3：玩家首次播种 → 触发阿恩递种夜谈
signal narration(text: String)   # 区块二：收获旁白浮字（旱象减产/丰收分邻等）
signal dialogue_request(id: String)   # 请求播放对话（由 DialogueManager 监听）
