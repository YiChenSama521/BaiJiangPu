local extension = Package:new("YC_Sheng")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Sheng/skills")

Fk:loadTranslationTable{
    ["YC_Sheng"] = "圣",
}

return extension