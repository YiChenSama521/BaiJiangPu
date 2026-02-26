local ba__zhinang = fk.CreateSkill {
  name = "ba__zhinang",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["ba__zhinang"] = "智囊",
  [":ba__zhinang"] = "持恒技，出牌阶段限一次，你可以随机获得2个<a href= ':ba__zhinang_trap'><font color = '#810080'>【陷阱】<font><a>。",
  [":ba__zhinang_trap"] = "【蜂蜜陷阱】：令随机一名敌方角色跳过其下一个回合。<br/>" ..
    "【树木掩护】：令所有友方角色获得一个“护甲”（防止一次伤害）。<br/>" ..
    "【马蜂窝】：随机两名敌方角色获得“被蛰了”（每个回合结束失去当前体力值上限25%的体力，持续一轮）。<br/>" ..
    "【吼叫】：令所有敌方角色弃置其所有手牌。",
  ["#ba__zhinang-active"] = "你可以发动【智囊】，随机获得2个【陷阱】",
  ["#ba__zhinang_trap_log"] = "%from 获得了陷阱：【%arg】",
  ["ba__zhinang_trap1"] = "蜂蜜陷阱",
  [":ba__zhinang_trap1"] = "令随机一名敌方角色跳过其下一个回合",
  ["ba__zhinang_trap2"] = "树木掩护",
  [":ba__zhinang_trap2"] = "令所有友方角色获得一个“护甲”（防止一次伤害）",
  ["ba__zhinang_trap3"] = "马蜂窝",
  [":ba__zhinang_trap3"] = "随机两名敌方角色获得“被蛰了”（每个回合结束失去当前体力值上限25%的体力，持续一轮）",
  ["ba__zhinang_trap4"] = "吼叫",
  [":ba__zhinang_trap4"] = "令所有敌方角色弃置其所有手牌",
  ["@@ba__BeiZheLe-round"] = "被蛰了",
  ["@ba__Shield"] = "护甲",
  ["@@ba__ChiFengMi"] = "吃了蜜",
  ["#honey_trap_log"] = "%from 对 %to 发动了【蜂蜜陷阱】，%to 将跳过其下一个回合",
}

ba__zhinang:addEffect("active", {
  anim_type = "control",
  prompt = "#ba__zhinang-active",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    for i = 1, 2 do
      local enemies = table.filter(room:getOtherPlayers(player), function(p) return p:isEnemy(player) end)
      local index = math.random(1, 4)
      room:sendLog{
        type = "#ba__zhinang_trap_log",
        from = player.id,
        arg = "ba__zhinang_trap"..index,
        toast = true,
      }
      if index == 4 then
        for _, p in ipairs(enemies) do
          if not p:isKongcheng() then
            p:throwAllCards("h", self.name)
          end
        end
      elseif index == 3 then
        local tos = table.random(enemies, 2)
        if #tos == 0 then return end
        for _, p in ipairs(tos) do
          player.room:setPlayerMark(p, "@@ba__BeiZheLe-round", 1)
        end
      elseif index == 2 then
        local tos = table.filter(room.alive_players, function(p) return p:isFriend(player) end)
        if #tos == 0 then return end
        for _, p in ipairs(tos) do
          player.room:addPlayerMark(p, "@ba__Shield", 1)
        end
      elseif index == 1 then
        local tos = table.random(enemies, 1)
        if #tos == 0 then return end
        player.room:setPlayerMark(tos[1], "@@ba__ChiFengMi", 1)
      end
    end
  end,
})

ba__zhinang:addEffect(fk.TurnStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ba__ChiFengMi") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:doAnimate("InvokeSkill", {
      name = "@@ba__ChiFengMi",
      player = player.id,
      skill_type = "negative",
    })
    player.room:endTurn()
    player.room:setPlayerMark(player, "@@ba__ChiFengMi", 0)
  end,
})

ba__zhinang:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@ba__BeiZheLe-round") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:doAnimate("InvokeSkill", {
      name = "@@ba__BeiZheLe-round",
      player = player.id,
      skill_type = "negative",
    })
    local lose = math.max(1, math.floor(target.maxHp * 0.25))
    player.room:loseHp(target, lose, self.name)
  end,
})

ba__zhinang:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@ba__Shield") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
    player.room:removePlayerMark(target, "@ba__Shield", 1)
  end,
})

ba__zhinang:addAI(Fk.Ltk.AI.newActiveStrategy {
  use_priority = 9,
  use_value = 9,
  think = function(self, ai)
    local player = ai.player
    local room = player.room
    local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    local friends = table.filter(room:getAlivePlayers(), function(p) return player:isFriend(p) end)
    local function scoreTrap(index)
      if index == 1 then
        local skip_val = 0
        for _, p in ipairs(enemies) do
          skip_val = skip_val + p.maxHp * 40 + #p:getCardIds("hej") * 20
        end
        return skip_val * 0.5
      elseif index == 2 then
        return #friends * 200
      elseif index == 3 then
        local val = 0
        for _, p in ipairs(enemies) do
          val = val + math.max(1, math.floor(p.maxHp * 0.25)) * 60
        end
        return val
      elseif index == 4 then
        local val = 0
        for _, p in ipairs(enemies) do
          val = val + #p:getCardIds("h") * 50
        end
        return val
      end
      return 0
    end
    local scores = {}
    for i = 1, 4 do
      scores[i] = scoreTrap(i)
    end
    local best1, best2 = 1, 2
    for i = 2, 4 do
      if scores[i] > scores[best1] then
        best2 = best1
        best1 = i
      elseif scores[i] > scores[best2] then
        best2 = i
      end
    end
    local total_val = scores[best1] + scores[best2]
    if total_val <= 0 then
      return nil, -1
    end
    local subcards = {}
    local targets = {}
    local extra = { trap1 = best1, trap2 = best2 }
    return { subcards, targets, extra }, total_val
  end
})

return ba__zhinang