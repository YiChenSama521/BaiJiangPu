local ba__xieqifanshi = fk.CreateSkill {
  name = "ba__xieqifanshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
    ["ba__xieqifanshi"] = "邪气反噬",
    [":ba__xieqifanshi"] = "锁定技，当你失去技能时，你失去当前体力值50%的体力、1枚“真气”。当你进入濒死状态时，你弃置所有“领悟”，将体力值回复至1点。",
}

ba__xieqifanshi:addEffect(fk.EventLoseSkill, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__xieqifanshi.name) and data.skill.name ~= ba__xieqifanshi.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, math.ceil(player.hp / 2), ba__xieqifanshi.name)
    room:addPlayerMark(player, "@ba__zhenqi", -1)
  end,
})

ba__xieqifanshi:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__xieqifanshi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@ba__lingwu", 0)
    if player.hp < 1 then
      player.room:recover({
        who = player,
        num = 1 - player.hp,
        skillName = ba__xieqifanshi.name
      })
    end
  end,
})

return ba__xieqifanshi