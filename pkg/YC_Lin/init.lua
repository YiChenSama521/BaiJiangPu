local extension = Package:new("YC_Lin")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Lin/skills")

Fk:loadTranslationTable{
    ["YC_Lin"] = "灵",
}

return extension