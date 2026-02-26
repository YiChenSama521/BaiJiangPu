local TMS__duanju = fk.CreateSkill {
  name = "TMS__duanju",
}

Fk:loadTranslationTable {
  ["TMS__duanju"] = "断举",
  [":TMS__duanju"] = "回合开始时，你可以令一名角色展示X张牌，并将其中的一种类别依次使用之，若未造成伤害，你与其各流失一点体力(X为你的体力值)。",
  ["#TMS__duanju-active"] = "断举：是否对一名角色发动？",
  ["#TMS__duanju-choose"] = "选择一名其他角色",
  ["#TMS__duanju-show"] = "断举：请展示 %arg 张手牌",
  ["#TMS__duanju-use"] = "断举：请使用 %arg",
  ["TMS__duanju-Basic"] = "基本牌",
  ["TMS__duanju-Trick"] = "锦囊牌",
  ["TMS__duanju-Equip"] = "装备牌",
}

TMS__duanju:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.hp > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:askToChoosePlayers(player, {
      targets = table.filter(room:getOtherPlayers(player), function(p)
        return not p:isKongcheng()
      end),
      min_num = 1,
      max_num = 1,
      skill_name = self.name,
      prompt = "#TMS__duanju-choose",
      cancelable = true,
    })
    if #targets == 0 then return end
    local to = targets[1]

    local num = math.min(to:getHandcardNum(), player.hp)
    if num == 0 then return end

    local cards = room:askToCards(to, {
      min_num = num,
      max_num = num,
      skill_name = self.name,
      prompt = "#TMS__duanju-show::" .. player.id .. ":" .. num,
      cancelable = false,
      include_equip = false,
      pattern = ".|.|.|hand",
    })

    if not cards or #cards == 0 then
      cards = to:getCardIds("h")
      if #cards > num then
        cards = table.random(cards, num)
      end
    end

    room:showCards(cards, to)

    local types = { ["TMS__duanju-Basic"] = false, ["TMS__duanju-Trick"] = false, ["TMS__duanju-Equip"] = false }
    for _, id in ipairs(cards) do
      local c = Fk:getCardById(id)
      if c.type == Card.TypeBasic then types["TMS__duanju-Basic"] = true end
      if c.type == Card.TypeTrick then types["TMS__duanju-Trick"] = true end
      if c.type == Card.TypeEquip then types["TMS__duanju-Equip"] = true end
    end

    local choices = {}
    if types["TMS__duanju-Basic"] then table.insert(choices, "TMS__duanju-Basic") end
    if types["TMS__duanju-Trick"] then table.insert(choices, "TMS__duanju-Trick") end
    if types["TMS__duanju-Equip"] then table.insert(choices, "TMS__duanju-Equip") end

    if #choices == 0 then return end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = self.name,
    })

    local to_use = {}
    for _, id in ipairs(cards) do
      local c = Fk:getCardById(id)
      local match = false
      if choice == "TMS__duanju-Basic" and c.type == Card.TypeBasic then match = true end
      if choice == "TMS__duanju-Trick" and c.type == Card.TypeTrick then match = true end
      if choice == "TMS__duanju-Equip" and c.type == Card.TypeEquip then match = true end
      if match then table.insert(to_use, id) end
    end

    room:setPlayerMark(to, "TMS__duanju_target", 1)

    for _, id in ipairs(to_use) do
      if to.dead then break end
      if table.contains(to:getCardIds("h"), id) then
        local c = Fk:getCardById(id)
        if to:canUse(c) then
          local useData = room:askToUseCard(to, {
            pattern = ".|.|.|.|.|.|" .. id,
            prompt = "#TMS__duanju-use:::" .. c:toLogString(),
            cancelable = false,
            skill_name = self.name,
          })
          if useData then
            room:useCard(useData)
          end
        end
      end
    end

    local damage_dealt = to:getMark("TMS__duanju_damage") > 0
    room:setPlayerMark(to, "TMS__duanju_target", 0)
    room:setPlayerMark(to, "TMS__duanju_damage", 0)

    if not damage_dealt then
      if not player.dead then room:loseHp(player, 1, self.name) end
      if not to.dead then room:loseHp(to, 1, self.name) end
    end
  end,
})

-- 监听断举目标造成的伤害，用于结算“若其未造成伤害则各失去1点体力”
TMS__duanju:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from:getMark("TMS__duanju_target") > 0
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    data.from.room:setPlayerMark(data.from, "TMS__duanju_damage", 1)
  end,
})

return TMS__duanju
