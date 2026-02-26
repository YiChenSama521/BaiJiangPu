local extension = Package:new("YC_Gui")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Gui/skills")

Fk:loadTranslationTable{
    ["YC_Gui"] = "鬼",
}

return extension