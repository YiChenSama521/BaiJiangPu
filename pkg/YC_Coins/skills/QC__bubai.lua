local qc__bubai = fk.CreateSkill({
    name = "qc__bubai",
    tags = { Skill.Permanent, Skill.Compulsory },
})
Fk:loadTranslationTable{
    ["qc__bubai"] = "不败",
    [":qc__bubai"] = "永恒技，全场【战力值】之和小于100时，你不会死亡。当全场【战力值】之和大于等于100时，你获得游戏胜利。",
}
--永恒技实现，放置在最上方
qc__bubai:addLoseEffect(function(self, player, is_death)
    local room = player.room
    room:handleAddLoseSkills(player, qc__bubai.name, nil, false, true)
end)

qc__bubai:addEffect(fk.AskForPeachesDone, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
      return target == player and player:hasSkill(self.name) and player.hp <= 0 and player.dying
  end,
  on_refresh = function(self, event, target, player, data)
    data.ignoreDeath = true
    local room = player.room
    room:setPlayerProperty(player, "hp", 66)
    room:setPlayerProperty(player, "maxHp", 66)
  end,
})

qc__bubai:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  global = true,
  priority = 9999999999999999999999999999999999999999999,
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, true)
    room:setPlayerProperty(player, "hp", 66)
    room:setPlayerProperty(player, "maxHp", 66)
  end,
})

qc__bubai:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:getMark("@qc__zhanli") >= 100
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:gameOver(player.role)
  end,
})

return qc__bubai
