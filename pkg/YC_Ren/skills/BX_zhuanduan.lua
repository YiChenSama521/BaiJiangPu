local BX_zhuanduan = fk.CreateSkill({
    name = "BX_zhuanduan",
    tags = { Skill.Wake },
})

Fk:loadTranslationTable {
    ["BX_zhuanduan"] = "专断",
    [":BX_zhuanduan"] = "觉醒技，当你累计造成或受到3点伤害后，你选择一名角色并选择一项。<br>1. 增加1点体力上限并回复1点体力，若其有〖死士〗则修改〖死士〗中的一个数字＋2。<br>2. 此后你的非延迟锦囊牌（【借刀杀人】除外）可额外指定一名其他角色为目标。",
}










return BX_zhuanduan