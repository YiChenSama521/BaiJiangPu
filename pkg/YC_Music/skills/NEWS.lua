local NEWS = fk.CreateSkill {
  name = "NEWS",
  tags = {Skill.Permanent},
}

Fk:loadTranslationTable {
  ["NEWS"] = "新三梗大王",
  [":NEWS"] = "新三梗播放器",
  ["$NEWS1"] = "不可能，绝对不可能",
  ["$NEWS2"] = "不要愤怒，愤怒会降低你的智慧",
  ["$NEWS3"] = "吃什么是啊",
  ["$NEWS4"] = "当浮一大白",
  ["$NEWS5"] = "都有伯牙舒淇之才",
  ["$NEWS6"] = "徐州城不愧为中原第一雄关！",
  ["$NEWS7"] = "风从虎云从龙龙虎英雄傲苍穹",
  ["$NEWS8"] = "恭喜爹可以称帝了",
  ["$NEWS9"] = "此处应有关羽之歌",
  ["$NEWS10"] = "来换大盏",
  ["$NEWS11"] = "已成骄兵而骄兵必败",
  ["$NEWS12"] = "竟然不许",
  ["$NEWS13"] = "龙，可是帝王之征啊",
  ["$NEWS14"] = "列位诸公",
  ["$NEWS15"] = "一把叫仁之剑一把叫义之剑",
  ["$NEWS16"] = "生死不明那就是死了",
  ["$NEWS17"] = "死不可怕，死是凉爽的夏夜",
  ["$NEWS18"] = "那好啊！他过江我也过江",
  ["$NEWS19"] = "我二弟天下无敌",
  ["$NEWS20"] = "我的大斧早就饥渴难耐了",
  ["$NEWS21"] = "咱家不怕酸",
  ["$NEWS22"] = "这就不奇怪了",
  ["$NEWS23"] = "扎龙自己的耳朵",
  ["$NEWS24"] = "这是谁的部将",
  ["$NEWS25"] = "自刎归天",
}

NEWS:addEffect("active", {
 can_use = Util.FalseFunc,
 on_use = function(self, room, effect)
 end,
})

return NEWS
