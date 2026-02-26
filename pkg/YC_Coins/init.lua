local extension = Package:new("YC_Coins")
extension.extensionName = "BaiJiangPu"

extension:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/YC_Coins/skills")

Fk:loadTranslationTable{
    ["YC_Coins"] = "金币投稿",
}

local QC__huayaweiyan = General:new(extension, "QC__huayaweiyan", "god" , 9 , 9 , General.Male)
QC__huayaweiyan:addSkills {  "qc__huajing", "qc__huaxian", "qc__shoubai","qc__wuya"}
Fk:loadTranslationTable{
    ["QC"] = "🥬",
    ["QC__huayaweiyan"] = "画涯·未颜",
    ["designer:QC__huayaweiyan"] = "青菜白玉汤",
    ["#QC__huayaweiyan"] = "丹青无涯",
}

local QC__shengzhantianqi = General:new(extension,"QC__shengzhantianqi","god",66,66,General.Male)
QC__shengzhantianqi:addSkills{ "qc__zhanli", "qc__zhanming", "qc__yongzhan", "qc__bubai", "qc__shengqu", }
QC__shengzhantianqi:addRelatedSkill("qc__zhanxin")
Fk:loadTranslationTable{
    ["QC"] = "🥬",
    ["QC__shengzhantianqi"] = "圣战天启",
    ["designer:QC__shengzhantianqi"] = "青菜白玉汤",
    ["#QC__shengzhantianqi"] = "永恒的战士",
}

local QC__guanyu = General:new(extension,"QC__guanyu","shu",4,4,General.Male)
QC__guanyu:addSkills{ "qc__wusheng", "qc__guanbinu", }
Fk:loadTranslationTable{
    ["QC"] = "🥬",
    ["QC__guanyu"] = "标关羽",
    ["designer:QC__guanyu"] = "青菜白玉汤",
    ["#QC__guanyu"] = "权一不敌标关",
}





return extension