local qc__guanbinu = fk.CreateSkill({
  name = "qc__guanbinu",
  tags = {Skill.Compulsory},
})
Fk:loadTranslationTable{
  ["qc__guanbinu"] = "关必弩",
  [":qc__guanbinu"] = "锁定技，你使用【杀】无距离次数限制。",
}

qc__guanbinu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return player:hasSkill(qc__guanbinu.name) and card.trueName == "slash"
  end,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(qc__guanbinu.name) and card.trueName == "slash"
  end,
})

return qc__guanbinu
