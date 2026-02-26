local extension = Package:new("YC_Music")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Music/skills")

local YC_XSYYH = General:new(extension, "YC_XSYYH", "god", 350, 234)
YC_XSYYH:addSkills {"NEWS",}
YC_XSYYH.hidden = true

Fk:loadTranslationTable{
    ["YC_Music"] = "乐",
    ["YC_XSYYH"] = "新三音乐盒",
    ["$qss1"] = "",
    ["$qss2"] = "",
    ["$qss3"] = "",
    ["$dsd1"] = "",
    ["$dsd2"] = "",
    ["$dsd3"] = "",
}

return extension