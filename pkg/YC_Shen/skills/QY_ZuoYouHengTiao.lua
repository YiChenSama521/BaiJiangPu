local zuoyouhengtiao = fk.CreateSkill {
  name = "zuoyouhengtiao",
  tags = {Skill.Permanent},
}

Fk:loadTranslationTable{
  ["zuoyouhengtiao"] = "左右横跳",
  [":zuoyouhengtiao"] = "持恒技，你可以将最左侧手牌视为【闪】使用或打出，将最右侧手牌视为【无懈可击】使用或打出。",
}

zuoyouhengtiao:addEffect("viewas", {
  anim_type = "defensive",
  pattern = "jink,nullification",
  prompt = "#zuoyouhengtiao",
  handly_pile = false,
  interaction = function(self, player)
    local names = {}
    for _, name in ipairs({"nullification", "jink"}) do
      local to_use = Fk:cloneCard(name)
      if ((Fk.currentResponsePattern == nil and player:canUse(to_use) and not player:prohibitUse(to_use)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
        table.insert(names, name)
      end
    end
    return UI.CardNameBox {choices = names}
  end,
  card_num = 0,
  before_use = function(self, player, use)
    player.room:syncPlayerClientCards(player)
    local id = player:getCardIds("h")[1]
    if self.interaction.data == "nullification" then
      local left_num = #player:getCardIds("h")
      id = player:getCardIds("h")[left_num]
    end
    if id then
      use.card:addSubcard(id)
    else
      return zuoyouhengtiao.name
    end
  end,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = function(self, player)
    return #player:getCardIds("h") > 0 and player:hasSkill(zuoyouhengtiao.name)
  end,
  enabled_at_response = function(self, player)
    return #player:getCardIds("h") > 0 and player:hasSkill(zuoyouhengtiao.name)
  end,
})

return zuoyouhengtiao
