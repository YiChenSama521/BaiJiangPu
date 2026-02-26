local extension = Package:new("YC_Xian")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Xian/skills")

Fk:loadTranslationTable{
    ["YC_Xian"] = "仙",
}
--左慈
local hl__zuoci = General:new(extension, "hl__zuoci", "qun" , 3 , 3 , General.Male)
hl__zuoci:addSkills {
  "hl_huashen",
}
Fk:loadTranslationTable{
  ["hl"] = "🦊",
  ["hl__zuoci"] = "左慈",
  ["designer:hl__zuoci"] = "官方加强",
  ["#hl__zuoci"] = "幻化众生",
}
--八二无名
local hl__wuming = General:new(extension, "hl__wuming", "qun", 4, 4)
hl__wuming:addSkills {"hl__chushan"}
Fk:loadTranslationTable {
    ["hl"] = "🦊",
    ["hl__wuming"] = "八二无名",
    ["designer:hl__zuoci"] = "官方加强",
    ["#hl__zuoci"] = "无名之人",
}



return extension