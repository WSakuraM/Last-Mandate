extends Node
# 《末命》全局事件总线（自动加载）
# 用于解耦：世界 <-> UI <-> 系统。

signal interact_prompt(text: String)
signal interact_hide()
signal open_issue(data: Dictionary)
signal meishan_begin()
signal first_sow()   # M1A3：玩家首次播种 → 触发阿恩递种夜谈
