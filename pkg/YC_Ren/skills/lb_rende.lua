local lb_rende = fk.CreateSkill({ name = "lb_rende", })

Fk:loadTranslationTable {
  ["lb_rende"] = "仁德",
  [":lb_rende"] = "①你的每个准备阶段开始时，你获得2枚“仁望”标记；<br>②出牌阶段，你可以选择一名其他角色，交给其任意张牌，然后你获得等量枚“仁望”标记；<br>③每回合限2次，当你需要使用或打出基本牌时，你可以移去2枚“仁望”标记，视为使用或打出之。",
  ["#lb_rende-active"] = "你可以发动“仁德”将任意张手牌交给一名其他角色，然后你获得等量枚”仁望”标记。",
  ["@lb_rende_cards"] = "仁望",
  ["#lb_rende-invoke"] = "仁德：可以移去2枚“仁望”标记，视为使用或打出 %arg",
  ["#lb_rende-name"] = "仁德：选择视为使用或打出的所需的基本牌的牌名",
  ["#lb_rende-target"] = "仁德：选择使用【%arg】的目标角色",
  ["#lb_rende_response"] = "仁望",
  ["#lb_rende-promot"] = "仁望：将牌交给其他角色获得“仁望”标记，或移去标记视为使用基本牌",
}

lb_rende:addEffect("active", {
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,

  prompt = "#lb_rende-promot",
  interaction = function(self, player)
    local choices = { "@lb_rende_cards" }
    if player:getMark("@lb_rende_cards") > 1 and player:getMark("lb_rende_vs-turn") < 2 then
      local all_names = Fk:getAllCardNames("b")
      table.insertTable(choices, player:getViewAsCardNames(lb_rende.name, all_names))
    end
    return UI.ComboBox { choices = choices }
  end,

  card_filter = function(self, player, to_select, selected)
    return self.interaction.data == "@lb_rende_cards"
  end,

  target_filter = function(self, player, to_select, selected, selected_cards)
    if self.interaction.data == "@lb_rende_cards" then
      return
          #selected == 0 and to_select ~= player
    elseif self.interaction.data ~= nil then
      local to_use = Fk:cloneCard(self.interaction.data)
      to_use.skillName = lb_rende.name
      if (#selected == 0 or to_use.multiple_targets) and player:isProhibited(to_select, to_use) then
        return false
      end
      return to_use.skill:targetFilter(player, to_select, selected, selected_cards, to_use)
    end
  end,
  --判断卡牌选择和目标数量合法性
  feasible = function(self, player, selected, selected_cards)
    if self.interaction.data == "@lb_rende_cards" then
      return #selected_cards > 0 and #selected == 1
    else
      local to_use = Fk:cloneCard(self.interaction.data)
      to_use.skillName = lb_rende.name
      return to_use.skill:feasible(player, selected, selected_cards, to_use)
    end
  end,
  --给牌获得对应数量仁望标记
  on_use = function(self, room, effect)
    ---@type string
    local skillName = lb_rende.name
    local player = effect.from
    if self.interaction.data == "@lb_rende_cards" then
      local target = effect.tos[1]
      room:setPlayerMark(target, "lb_rende_target-phase", 2)
      local mark = player:getTableMark("lb_rende_target")
      if table.insertIfNeed(mark, target.id) then
        room:setPlayerMark(player, "lb_rende_target", mark)
      end
      room:moveCardTo(effect.cards, Player.Hand, target, fk.ReasonGive, skillName, nil, false, player)
      if not player:isAlive() then return end
      room:setPlayerMark(player, "@lb_rende_cards", math.min(player:getMark("@lb_rende_cards") + #effect.cards))
    else
      room:removePlayerMark(player, "@lb_rende_cards", 2)
      room:addPlayerMark(player, "lb_rende_vs-turn", 1)
      local use = {
        from = player,
        tos = effect.tos,
        card = Fk:cloneCard(self.interaction.data),
      }
      use.card.skillName = skillName
      room:useCard(use)
    end
  end,
})
-- 仁德专属判断
local lb_rendeTriggerViewAsCanTrigger = function(self, event, target, player, data)
  return
      target == player and
      player:hasSkill(lb_rende.name) and
      player:getMark("@lb_rende_cards") > 1 and
      player:getMark("lb_rende_vs-turn") < 2 and
      data.pattern and
      Exppattern:Parse(data.pattern):matchExp(".|.|.|.|.|basic")
end
-- 仁德专属选择
local lb_rendeTriggerViewAsOnCost = function(self, event, target, player, data)
  local basicCards = Fk:getAllCardNames("b")
  local names = {}
  for _, name in ipairs(basicCards) do
    local card = Fk:cloneCard(name)
    if Exppattern:Parse(data.pattern):match(card) then
      table.insertIfNeed(names, name)
    end
  end
  if #names > 0 then
    local name = names[1]
    if #names > 1 then
      name = table.every(names, function(str) return string.sub(str, -5) == "slash" end) and "slash" or "basic"
    end
    if player.room:askToSkillInvoke(player, { skill_name = lb_rende.name, prompt = "#lb_rende-invoke:::" .. name }) then
      event:setCostData(self, names)
      return true
    end
  end
end
-- 仁德回合外使用
lb_rende:addEffect(fk.AskForCardUse, {
  mute = true,
  can_trigger = lb_rendeTriggerViewAsCanTrigger,
  on_cost = lb_rendeTriggerViewAsOnCost,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = lb_rende.name
    local room = player.room
    local names = event:getCostData(self)
    local extra_data = data.extraData
    local isAvailableTarget = function(card, p)
      if extra_data then
        if type(extra_data.must_targets) == "table" and #extra_data.must_targets > 0 and
            not table.contains(extra_data.must_targets, p.id) then
          return false
        end
        if type(extra_data.exclusive_targets) == "table" and #extra_data.exclusive_targets > 0 and
            not table.contains(extra_data.exclusive_targets, p.id) then
          return false
        end
      end
      return not player:isProhibited(p, card) and card.skill:modTargetFilter(player, p, {}, card, extra_data)
    end
    local findCardTarget = function(card)
      local tos = {}
      for _, p in ipairs(room.alive_players) do
        if isAvailableTarget(card, p) then
          table.insert(tos, p)
        end
      end
      return tos
    end
    names = table.filter(names, function(c_name)
      local card = Fk:cloneCard(c_name)
      return not player:prohibitUse(card) and (card.skill:getMinTargetNum(player) == 0 or #findCardTarget(card) > 0)
    end)
    if #names == 0 then return false end
    local name = room:askToChoice(player, { choices = names, skill_name = skillName, prompt = "#lb_rende-name" })
    player:broadcastSkillInvoke(skillName)
    room:removePlayerMark(player, "@lb_rende_cards", 2)
    room:setPlayerMark(player, "lb_rende_vs-turn", 1)
    local card = Fk:cloneCard(name)
    card.skillName = skillName
    data.result = {
      from = player,
      card = card,
    }
    if card.skill:getMinTargetNum(player) == 1 then
      local tos = findCardTarget(card)
      if #tos == 1 then
        data.result.tos = tos
      elseif #tos > 1 then
        data.result.tos = room:askToChoosePlayers(
          player,
          {
            targets = tos,
            min_num = 1,
            max_num = 1,
            prompt = "#lb_rende-target:::" .. name,
            skill_name = skillName,
            cancelable = false,
            no_indicate = true
          }
        )
      else
        return false
      end
    end
    if data.eventData then
      data.result.toCard = data.eventData.toCard
      data.result.responseToEvent = data.eventData.responseToEvent
    end
    return true
  end
})
-- 阶段开始时，你拿2个仁望。
lb_rende:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lb_rende.name) and target == player and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@lb_rende_cards", math.min(player:getMark("@lb_rende_cards") + 2))
  end,
})

return lb_rende
