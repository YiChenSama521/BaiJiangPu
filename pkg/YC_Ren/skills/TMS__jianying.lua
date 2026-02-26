local TMS__jianying = fk.CreateSkill {
  name = "TMS__jianying",
}
Fk:loadTranslationTable{
  ["TMS__jianying"] = "渐营",
  [":TMS__jianying"] = "当你于出牌阶段使用牌时，你摸一张牌；"..
    "出牌阶段限一次，你可以将一张牌当做任意基本牌使用或打出。",
  ["#TMS__jianying-active"] = "你可以将一张牌当做任意基本牌使用或打出。",
  
  ["$TMS__jianying1"] = "遣精骑抄其边鄙，彼不得安，我取其逸。",
  ["$TMS__jianying2"] = "今北利在于缓搏，宜徐持久，旷以日月。",
}

TMS__jianying:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player.phase == Player.Play and player:hasSkill(TMS__jianying.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, TMS__jianying.name)
  end,
})

TMS__jianying:addEffect("viewas", {
  max_phase_use_time = 1,
  prompt = "#TMS__jianying-active",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(TMS__jianying.name, all_names),
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
    if Fk.all_card_types[self.interaction.data] == nil or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:setPlayerMark(player, "TMS__jianying_used-phase", 1)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("TMS__jianying_used-phase") == 0
  end,
})

return TMS__jianying