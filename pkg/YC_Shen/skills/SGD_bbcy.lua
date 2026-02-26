local sgd_bbcy = fk.CreateSkill {
  name = "sgd_bbcy",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["sgd_bbcy"] = "百步穿杨",
  [":sgd_bbcy"] = "永恒技，每轮开始时，你获得一枚“矍铄”标记。你每拥有一枚“矍铄”标记，你的体力值上限、护甲、摸牌阶段额外摸牌数、每回合首次受到伤害后的摸牌数+X（X为“矍铄”标记的数量）。<br>出牌阶段限三次，你可以将一张牌当【杀】使用或打出，此【杀】不计入次数限制，且目标修改为其他所有存活角色。",
  ["#sgd_bbcy"] = "出牌阶段限三次，你可以将一张牌当【杀】使用或打出，此【杀】不计入次数限制，且目标修改为所有存活角色。",
  ["@JueShuo"] = "矍铄",
  ["$sgd_bbcy1"] = "不得不服老啦。",
  ["$sgd_bbcy2"] = "吾虽年迈，箭矢犹锋！",
  ["$sgd_bbcy"] = "百步穿杨！",
}

sgd_bbcy:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_bbcy.name, nil, false, true)
end)

--每轮开始获得标记，体力值上限、护甲增加√
sgd_bbcy:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_bbcy.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@JueShuo", 1)
    room:changeMaxHp(player, 1)
    room:changeShield(player, 1)
  end,
})
-- 摸牌阶段摸牌数√
sgd_bbcy:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_bbcy.name) and target == player and player:getMark("@JueShuo") >= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@JueShuo")
  end,
})
-- 受伤时触发摸牌√
sgd_bbcy:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_bbcy.name) and target == player and player:getMark("@JueShuo") >= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getMark("@JueShuo"), sgd_bbcy.name)
  end
})
--出牌阶段限三次，你可以将一张牌当【杀】使用或打出，此【杀】不计入次数限制，且目标修改为所有存活角色。√
sgd_bbcy:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#sgd_bbcy",
  card_num = 1,
  pattern = "slash",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected, data)
    return #selected == 0 and player:usedSkillTimes(sgd_bbcy.name, Player.HistoryPhase) < 3
  end,
  interaction = function(self, player)
    local all_names = table.filter(Fk:getAllCardNames("b"), function(name)
      return Fk:cloneCard(name).trueName == "slash"
    end)
    local names = player:getViewAsCardNames(sgd_bbcy.name, all_names, nil, nil, { bypass_times = true })
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    use.tos = player.room:getOtherPlayers(player)
  end,
  view_as = function(self, player, cards)
    local choice = self.interaction.data
    if not choice or #cards ~= 1 then return end
    local c = Fk:cloneCard(choice)
    c:addSubcards(cards)
    c.skillName = sgd_bbcy.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(sgd_bbcy.name, Player.HistoryPhase) < 3
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:usedSkillTimes(sgd_bbcy.name, Player.HistoryPhase) < 3
  end,
})
--无次数
sgd_bbcy:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(card.skillNames, sgd_bbcy.name)
  end,
})

return sgd_bbcy
