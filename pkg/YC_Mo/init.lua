local extension = Package:new("YC_Mo")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Mo/skills")

Fk:loadTranslationTable{
    ["YC_Mo"] = "魔",
}

local YC__nianshou = General:new(extension, "YC__nianshou", "god", 4)
YC__nianshou:addSkills {
  "YC__zishu", "YC__chouniu", "YC__yinhu", "YC__maotu",
  "YC__chenlong", "YC__sishe", "YC__wuma", "YC__weiyang",
  "YC__shenhou", "YC__youji", "YC__xugou", "YC__haizhu"
}
Fk:loadTranslationTable{
  ["YC__nianshou"] = "发狂年兽",
}



return extension