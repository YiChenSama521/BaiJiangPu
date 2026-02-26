local YM_jiupinjinlian = fk.CreateSkill {
  name = "YM_jiupinjinlian",
  anim_type = "offensive",
  tags = { Skill.Permanent },
  max_branches_use_time = {
    ["sb"] = {
      [Player.HistoryGame] = 9
    },
  }
}

Fk:loadTranslationTable {
  ["YM_jiupinjinlian"] = "九品金莲",
  ["@jiupinjinlian"] = "九品金莲-",
  ["#YM_jiupinjinlianTTT"] = "九品金莲：你可对任意名角色造成9点伤害（第%arg次，共9次）",
  [":YM_jiupinjinlian"] = "永恒技。" ..
  "你可在一名其他角色使用牌与技能时主动进入濒死，当你濒死时你立即将体力上限与体力值调整至九并摸九张牌，然后对场上对任意名其他角色各造成9次9点伤害，可用九次。" ..
  "<br>其他角色每受到你以此法造成的伤害，其体力上限-1，以任何方式获得的牌数-1，本局造成伤害减1。以此递减。" ..
  "<br>你可在濒死阶段立即执行一个额外回合。",

  ["$YM_jiupinjinlian1"] = "东土众生，全赖教化，德昭日月。后七百年，此方国土，灵王勤政时，在此国土之西，当有释迦牟尼出世光大我道。",
}

YM_jiupinjinlian:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:handleAddLoseSkills(player, YM_jiupinjinlian.name, nil, false, true)
end)

local spec = {
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = YM_jiupinjinlian.name,
      prompt = "是否发动九品金莲？立即濒死",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addSkillBranchUseHistory(YM_jiupinjinlian.name, "sb", 1)
    room:setPlayerProperty(player, "hp", 0)
    room:enterDying({ who = player })
  end,
}

YM_jiupinjinlian:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(YM_jiupinjinlian.name, true, true) and target and target ~= player and
    YM_jiupinjinlian:withinBranchTimesLimit(player, "sb", Player.HistoryGame)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

YM_jiupinjinlian:addEffect(fk.SkillEffect, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(YM_jiupinjinlian.name, true, true) and target and target ~= player and
    YM_jiupinjinlian:withinBranchTimesLimit(player, "sb", Player.HistoryGame) and data.skill:isPlayerSkill(target)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

YM_jiupinjinlian:addEffect(fk.EnterDying, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(YM_jiupinjinlian.name, true, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
    room:drawCards(player, 9, YM_jiupinjinlian.name)
    if #room.alive_players == 0 then return end
    for i = 1, 9 do
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 99,
        targets = room.alive_players,
        skill_name = YM_jiupinjinlian.name,
        prompt = "#YM_jiupinjinlianTTT:::" .. i,
        cancelable = true,
      })
      if #to == 0 then
        break
      end
      for _, p in ipairs(to) do
        room:damage({
          from = player,
          to = p,
          damage = 9,
          skillName = YM_jiupinjinlian.name,
        })
        room:changeMaxHp(p, -1)
        room:addPlayerMark(p, "@jiupinjinlian", 1)
      end
    end
  end,
})

YM_jiupinjinlian:addEffect(fk.AskForPeaches, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(YM_jiupinjinlian.name, true, true) and player.dying
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = YM_jiupinjinlian.name,
      prompt = "九品金莲：是否立即执行一个额外回合？",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn(false)
  end,
})

YM_jiupinjinlian:addEffect(fk.DamageCaused, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:isAlive() and player:getMark("@jiupinjinlian") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = data.from:getMark("@jiupinjinlian")
    data.damage = math.max(data.damage - num, 0)
  end,
})

YM_jiupinjinlian:addEffect(fk.BeforeDrawCard, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:isAlive() and player:getMark("@jiupinjinlian") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = target:getMark("@jiupinjinlian")
    data.num = math.max(data.num - num, 0)
  end,
})


return YM_jiupinjinlian
