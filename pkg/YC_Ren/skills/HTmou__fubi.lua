local HTmou__fubi = fk.CreateSkill({
  name = "HTmou__fubi",
  tags = { Skill.Lord },
})

Fk:loadTranslationTable {
  ["HTmou__fubi"] = "复辟",
  [":HTmou__fubi"] = "主公技，每回合限X次，当其他吴势力角色的装备牌进入弃牌堆后，你可以令其获得之（X为游戏开始时其他吴势力角色数）。",
  ["#HTmou__fubi-1-invoke"] = "复辟：%arg进入弃牌堆，是否令 %dest 获得之？",
  ["#HTmou__fubi-2-invoke"] = "复辟：装备牌进入弃牌堆，是否令 %dest 获得之？",
}

HTmou__fubi:addEffect(fk.GameStart, {
  -- 延迟效果
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(HTmou__fubi.name) and
        table.find(player.room:getOtherPlayers(player), function(p)
          return p.kingdom == "wu"
        end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = #table.filter(room:getOtherPlayers(player), function(p)
      return p.kingdom == "wu"
    end)
    room:addPlayerMark(player, HTmou__fubi.name, x)
  end
})

HTmou__fubi:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard", -- 设置技能触发时的动画类型为抽牌动画
  can_trigger = function(self, event, target, player, data)
    -- 检查触发条件：玩家拥有此技能且本回合未使用过此技能且玩家不是空手牌
    if player:hasSkill(HTmou__fubi.name) and player:usedSkillTimes(HTmou__fubi.name, Player.HistoryTurn) < player:getMark(HTmou__fubi.name) then
      local cards = {} -- 创建一个空表来存储符合条件的装备牌
      local to
      -- 遍历所有卡牌移动事件
      for _, move in ipairs(data) do
        -- 检查卡牌是否移动到弃牌堆
        if move.from and move.from ~= player and move.from.kingdom == "wu" and move.toArea == Card.DiscardPile then
          -- 遍历移动信息中的每张卡牌
          for _, info in ipairs(move.moveInfo) do
            -- 检查卡牌是否为装备牌且确实在弃牌堆中
            if Fk:getCardById(info.cardId).type == Card.TypeEquip and table.contains(player.room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId) -- 将符合条件的卡牌ID添加到表中
              to = move.from
            end
          end
        end
      end
      -- 检查卡牌是否在移动后没有被再次移动
      cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
      -- 如果有符合条件的装备牌，设置消耗数据并返回true允许触发
      if #cards > 0 then
        event:setCostData(self, { card = cards, to = to })
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    -- 获取之前存储的装备牌列表
    local cards = table.simpleClone(event:getCostData(self).card)
    local to = event:getCostData(self).to
    local prompt = "#HTmou__fubi-2-invoke::" .. to.id-- 默认提示信息（多张装备牌时）
    -- 如果只有一张装备牌，使用更具体的提示信息
    if #cards == 1 then
      prompt = "#HTmou__fubi-1-invoke::" .. to.id .. ":" .. Fk:getCardById(cards[1]):toLogString()
    end
    -- 如果玩家选择了弃置牌，设置消耗数据并返回true
    if room:askToSkillInvoke(player, { skill_name = HTmou__fubi.name, prompt = prompt }) then
      event:setCostData(self, { cards = cards, to = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, event:getCostData(self).to, fk.ReasonJustMove,
    HTmou__fubi.name, nil, true, player)
  end,
})

return HTmou__fubi
