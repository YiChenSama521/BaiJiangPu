local extension = Package:new("YC_Shen")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Shen/skills")

Fk:loadTranslationTable{
  ["YC_Shen"] = "神",
}

local QiYu = General:new(extension, "QiYu", "god" , 999 , 999 , General.Male)
QiYu:addSkills {
  "putongquan",
  "lianxuputongquan",
  "renzhenyiquan",
  "zuoyouhengtiao"
}

Fk:loadTranslationTable{
  ["QiYu"] = "琦玉",
  ["designer:QiYu"] = "逸晨",
  ["#QiYu"] = "一拳超人",
}

local shen__wuhushangjiang = General:new(extension, "shen__wuhushangjiang", "shu", 7, 7, General.Male)
shen__wuhushangjiang:addSkills {
  "sgd_wzhx",
  "sgd_jsdq",
  "sgd_qjqc",
  "sgd_yqdq",
  "sgd_bbcy",
  "sgd_hzlx",
  "sgd_sl",
}
shen__wuhushangjiang:addRelatedSkills {"sgd_xh"}

Fk:loadTranslationTable{
  ["shen"] = "神",
  ["shen__wuhushangjiang"] = "神·五虎",
  ["designer:shen__wuhushangjiang"] = "逸晨",
  ["#shen__wuhushangjiang"] = "蜀汉之高达",
}

local shen__yaoqianshu = General:new(extension, "shen__yaoqianshu", "god", 88)
shen__yaoqianshu:addSkills {"yqs_laicai",}shen__yaoqianshu.hidden = true

Fk:loadTranslationTable{
  ["shen"] = "神",
  ["shen__yaoqianshu"] = "摇钱树",
  ["designer:shen__yaoqianshu"] = "逸晨",
  ["#shen__yaoqianshu"] = "来！来财",
}

local YM_xifangersheng = General:new(extension, "YM_xifangersheng", "qun", 0)
YM_xifangersheng:addSkills { "YM_jiupinjinlian", "YM_shengwei", "YM_puti", "YM_jieyin" }
Fk:loadTranslationTable {
  ["YM_xifangersheng"] = "西方二圣",
  ["#YM_xifangersheng"] = "施主与我西方有缘",
  ["designer:YM_xifangersheng"] = "焉民",
  ["cv:YM_xifangersheng"] = "无",
  ["illustrator:YM_xifangersheng"] = "未知",
}

return extension