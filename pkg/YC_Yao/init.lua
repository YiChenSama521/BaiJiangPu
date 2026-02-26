local extension = Package:new("YC_Yao")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Yao/skills")

Fk:loadTranslationTable {
    ["YC_Yao"] = "妖",
}
--灰太狼
local ba__lang = General:new(extension, "ba__lang", "wei", 3, 3, General.Male)
ba__lang.headnote = "人机拥有天气魔方时，玩家的天气魔方不会生效。"
ba__lang.hidden = true
ba__lang:addSkills { "ba__tianqimofang", "ba__tiancai", "ba__faming" }
Fk:loadTranslationTable {
    ["ba"] = "👮",
    ["ba__lang"] = "灰太狼",
    ["#ba__lang"] = "善战的狼",
}
local ba__lang_1 = General:new(extension, "ba__lang_1", "wei", 3, 3, General.Male)
ba__lang_1.total_hidden = true
Fk:loadTranslationTable {["ba__lang_1"] = "灰太狼",}
--食猴鹰
local ba__ying = General:new(extension, "ba__ying", "qun", 6, 6, General.Male)
ba__ying:addSkills {"ba__yingxiao", "ba__shihou"}
Fk:loadTranslationTable {
    ["ba"] = "👮",
    ["ba__ying"] = "食猴鹰",
    ["#ba__ying"] = "远见的鹰",
}
--大龙
local ba__bao = General:new(extension, "ba__bao", "qun", 9, 9, General.Male)
ba__bao:addSkills {"ba__wuxueqicai", "ba__zhenqi", "ba__xieqifanshi",}
Fk:loadTranslationTable {
    ["ba"] = "👮",
    ["ba__bao"] = "大龙",
    ["#ba__bao"] = "敏捷的豹",
}
--熊大熊二
local ba__xiong = General:new(extension, "ba__xiong", "qun", 12, 12, General.Male)
ba__xiong:addSkills {"ba__xiongditongxin", "ba__bhslxxyz", "ba__sgtkz",}
ba__xiong:addRelatedSkills {"ba__zhinang", "ba__manli", "ba__senlinzhinu",}
Fk:loadTranslationTable {
    ["ba"] = "👮",
    ["ba__xiong"] = "熊大熊二",
    ["#ba__xiong"] = "威猛的熊",
}



return extension
