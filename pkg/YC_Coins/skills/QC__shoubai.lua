local qc__shoubai = fk.CreateSkill({
  name = "qc__shoubai",
  tags = {Skill.Permanent, Skill.Compulsory},
})
Fk:loadTranslationTable{
  ["qc__shoubai"] = "守白",
  [":qc__shoubai"] = "永恒技，你可将一张牌当作任意牌使用或打出，若你当作【杀】或【桃】使用或打出，则该【杀】或【桃】的回复值或伤害值+X（X为该牌点数）。",
}
--永恒技实现，放置在最上方
qc__shoubai:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, qc__shoubai.name, nil, false, true)
end)

qc__shoubai:addEffect("viewas", {
  pattern = ".",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("btde")
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(self.name, all_names, player:getCardIds("he")),
      all_choices = all_names,
    }
  end,
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    local point = Fk:getCardById(cards[1]).number
    card.extra_data = card.extra_data or {}
    card.extra_data.shoubai_point = point
    return card
  end,
  enabled_at_play = function(self, player)
    return not player:isNude()
  end,
  enabled_at_response = function(self, player)
    return not player:isNude()
  end,
  enabled_at_nullification = function(self, player)
    return not player:isNude()
  end,
})

qc__shoubai:addEffect(fk.DetermineDamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.from == player and data.card and data.card:isVirtual() and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
      data.damage = data.damage + data.card.number
  end,
})

qc__shoubai:addEffect(fk.PreHpRecover, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.card and data.card:isVirtual() and data.card.trueName == "peach"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
      data:changeRecover(data.card.number)
  end,
})

return qc__shoubai