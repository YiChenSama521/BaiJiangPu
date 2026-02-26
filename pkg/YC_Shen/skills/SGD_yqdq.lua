local sgd_yqdq = fk.CreateSkill({
  name = "sgd_yqdq",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["sgd_yqdq"] = "一骑当千",
  [":sgd_yqdq"] = "永恒技，游戏开始时/回合开始时/当你受到伤害后，你选择一名其他角色为“仇敌”。<br>“仇敌”角色无法使用、打出、弃置手牌，失去所有技能并且无法获得技能。且当“仇敌”角色体力值/体力值上限变化时直接死亡。",
  ["@@ChouDi"] = "仇敌",
  ["#ChouDi-choose"] = "仇敌:请选择一个“仇敌”",
  ["$sgd_yqdq1"] = "誓要让手中银枪饱饮鲜血！",
  ["$sgd_yqdq2"] = "父仇在胸，国恨在目，西凉马超，誓杀曹贼！",
  ["$sgd_yqdq3"] = "不枭曹贼之首祀于父前，吾枉为人子！",
}

sgd_yqdq:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, sgd_yqdq.name, nil, false, true)
end)

-- “仇敌”角色无法使用、打出、弃置手牌
sgd_yqdq:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@ChouDi") == 1 and card then
      local subcards = card:isVirtual() and card.subcards or { card.id }
      return #subcards > 0 and
          table.every(subcards, function(id)
            return table.contains(player:getCardIds("h"), id)
          end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@ChouDi") == 1 and card then
      local subcards = card:isVirtual() and card.subcards or { card.id }
      return #subcards > 0 and
          table.every(subcards, function(id)
            return table.contains(player:getCardIds("h"), id)
          end)
    end
  end,
  prohibit_discard = function(self, player, card)
    return player:getMark("@@ChouDi") == 1 and card
  end,
})
-- 添加无法获得技能的效果
sgd_yqdq:addEffect(fk.EventAcquireSkill, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_yqdq.name) and target ~= player and target:getMark("@@ChouDi") == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if target:getMark("@@ChouDi") == 1 then
      player.room:handleAddLoseSkills(target, "-" .. data.skill.name, nil)
    end
  end
})
-- 添加体力值变化时直接死亡的效果
sgd_yqdq:addEffect(fk.HpChanged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_yqdq.name) and target:getMark("@@ChouDi") == 1 and data.skillName ~= sgd_yqdq.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:killPlayer({ who = target, skillName = self.name, })
  end
})
-- 添加体力值上限变化时直接死亡的效果
sgd_yqdq:addEffect(fk.MaxHpChanged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_yqdq.name) and target:getMark("@@ChouDi") == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:killPlayer({ who = target, skillName = self.name, })
  end
})
--选择一名其他角色为“仇敌”
local spec = {
  can_trigger = function(self, event, target, player, data)
    return target == player and
    player:hasSkill(self.name) and
    #player.room:getOtherPlayers(player, false) > 0 and
        player:getMark("@@ChouDi") ~= 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      max_num = 1,
      min_num = 1,
      prompt = "#ChouDi-choose",
      skill_name = sgd_yqdq.name,
      cancelable = false,
    })[1]
    if to then
      event:setCostData(self, { to = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    -- 给标记
    local room = target.room
    local to = event:getCostData(self).to
    room:setPlayerMark(to, "@@ChouDi", 1)
    -- 添加失去所有技能的效果
    local skills = to:getSkillNameList()
    if #skills > 0 then
      room:handleAddLoseSkills(to, "-" .. table.concat(skills, "|-"), nil, true, false)
    end
  end
}

sgd_yqdq:addEffect(fk.GameStart, spec)   -- 游戏开始
sgd_yqdq:addEffect(fk.Damaged, spec) -- 受到伤害后 
sgd_yqdq:addEffect(fk.EventPhaseStart, { -- 准备阶段
  can_trigger = function(self, event, target, player, data)
    return target == player and
    player:hasSkill(self.name) and
    player.phase == Player.Start and
    #player.room:getOtherPlayers(player, false) > 0 and
    player:getMark("@@ChouDi") ~= 1
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return sgd_yqdq
