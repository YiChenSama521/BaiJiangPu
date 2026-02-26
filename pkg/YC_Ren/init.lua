local extension = Package:new("YC_Ren")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Ren/skills")

Fk:loadTranslationTable{
    ["YC_Ren"] = "人",
}
-- 义·刘备
local yi__liubei = General:new(extension, "yi__liubei", "shu" , 4 , 4 , General.Male)
yi__liubei:addSkills {
  "lb_rende",
  "lb_jishan",
  "lb_jiansheng",
  "lb_jijiang",
}
Fk:loadTranslationTable{
    ["yi"] = "义",
    ["yi__liubei"] = "义刘备",
    ["designer:yi__liubei"] = "逸晨",
    ["#yi__liubei"] = "义薄云天",
}
-- 谋孙策
local HTmou__sunce = General:new(extension, "HTmou__sunce", "wu" , 4 , 4 , General.Male)
HTmou__sunce:addSkills {
  "HTmou__jidou",
  "HTmou__zhuangzhi",
  "HTmou__fubi",
}
Fk:loadTranslationTable{
    ["HTmou"] = "谋",
    ["HTmou__sunce"] = "谋孙策",
    ["designer:HTmou__sunce"] = "hentai",
    ["#HTmou__sunce"] = "江东的小霸王",
}
-- 司马师
-- local BX_simashi = General:new(extension, "BX_simashi", "jin", 4, 5 , General.Male)
-- BX_simashi.subkingdom = "wei"
-- BX_simashi:addSkills {
--     "BX_sishi",
--     "BX_zhuanduan",
--     "BX_qianzhen",
-- }
-- Fk:loadTranslationTable{
--     ["BX_simashi"] = "司马师",
--     ["designer:BX_simashi"] = "北杏",
-- }
-- 郭汜
local YAN__guosi = General:new(extension, "YAN__guosi", "qun", 4 , 4 , General.Male)
YAN__guosi:addSkills {
    "YAN__qianglue",
    "YAN__xiongjun",
}
Fk:loadTranslationTable{
    ["YAN"] = "焉",
    ["YAN__guosi"] = "郭汜",
    ["designer:YAN__guosi"] = "焉",
}
-- 王基
local TMS__wangji = General:new(extension, "TMS__wangji", "wei", 3 , 3 , General.Male)
TMS__wangji:addSkills {
    "TMS__duanju", "TMS__bingqi", "TMS__juexing",
}
Fk:loadTranslationTable{
    ["TMS"] = "锑纆庶",
    ["TMS__wangji"] = "王基",
    ["designer:TMS__wangji"] = "锑纆庶",
    ["#TMS__wangji"] = "军令不受",
}
-- 沮授
local TMS__jvshou = General:new(extension, "TMS__jvshou", "qun", 2, 3, General.Male)
TMS__jvshou.shield = 3
TMS__jvshou:addSkills {
    "TMS__jianying", "TMS__shibei", "TMS__hongli"
}
Fk:loadTranslationTable{
    ["TMS"] = "锑纆庶",
    ["TMS__jvshou"] = "沮授",
    ["designer:TMS__jvshou"] = "锑纆庶",
    ["#TMS__jvshou"] = "初冬观雪",
    ["~TMS__jvshou"] = "公信顺耳之言，终误匡汉大业啊……",
}

return extension