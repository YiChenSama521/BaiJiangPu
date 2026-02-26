local TMS__juexing = fk.CreateSkill{
  name = "TMS__juexing",
  tags = {Skill.Compulsory},
}
Fk:loadTranslationTable{
  ["TMS__juexing"] = "决行",
  [":TMS__juexing"] = "锁定技，当你成为【杀】的目标时，你弃置使用者的一张牌，下次你对其造成的伤害+1（可叠加）。",
}

TMS__juexing:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and data.to:hasSkill(self.name) and data.card and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(data.from, "TMS__juexing_damage", 1)
    local cards = player.room:askToChooseCards(data.to, {
          target = data.from,
          min = 1,
          max = 1,
          flag = "he",
          skill_name = self.name,
        })
    player.room:throwCard(cards, self.name, data.from, data.to)
  end,
})

TMS__juexing:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local bonus = data.to:getMark("TMS__juexing_damage")
    data.damage = data.damage + bonus
    player.room:setPlayerMark(data.to, "TMS__juexing_damage", 0)
  end,
})

return TMS__juexing
