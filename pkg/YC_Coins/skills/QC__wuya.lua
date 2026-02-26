local qc__wuya = fk.CreateSkill({
  name = "qc__wuya",
  tags = {Skill.Permanent, Skill.Compulsory},
})
Fk:loadTranslationTable{
  ["qc__wuya"] = "无涯",
  [":qc__wuya"] = "永恒技，当你即将死亡时防止之并将体力回复至体力上限。",
}
--永恒技实现，放置在最上方
qc__wuya:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, qc__wuya.name, nil, false, true)
end)

qc__wuya:addEffect(fk.EnterDying, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("qc__wuya", true, true) and (player.dying or player.dead)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
  end,
})

qc__wuya:addEffect(fk.AskForPeachesDone, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
      return target == player and player.hp <= 0 and player.dying and player:hasSkill("qc__wuya", true, true)
  end,
  on_use = function(self, event, target, player, data)
    data.ignoreDeath = true
    local room = player.room
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
  end,
})

qc__wuya:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("qc__wuya", true, true) and (player.dying or player.dead)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
  end,
})

return qc__wuya