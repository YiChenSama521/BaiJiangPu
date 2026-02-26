local extension = Package:new("YC_Hun")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Hun/skills")

Fk:loadTranslationTable{
    ["YC_Hun"] = "魂",
}

return extension