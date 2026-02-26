local ba__bhslxxyz = fk.CreateSkill {
  name = "ba__bhslxxyz",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["ba__bhslxxyz"] = "保护森林！熊熊有责！",
  [":ba__bhslxxyz"] = "持恒技，当你或一名友方角色受到伤害时，你可以失去1点体力，防止此伤害。",
  ["#bhslxxyz-cost"] = "是否发动【保护森林！熊熊有责！】失去1点体力，防止 %dest 的伤害？",
}

ba__bhslxxyz:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (target == player or not target:isEnemy(player)) and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#bhslxxyz-cost::" .. target.id })
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    return data:preventDamage()
  end,
})

return ba__bhslxxyz