local qc__yongzhan = fk.CreateSkill({
    name = "qc__yongzhan",
    tags = { Skill.Permanent, Skill.Compulsory },
})
Fk:loadTranslationTable{
    ["qc__yongzhan"] = "永战",
    [":qc__yongzhan"] = "永恒技，当你造成伤害后，你可以重置你所有技能的使用次数；你的回合开始时，你回复X点体力值（X为你的【战力值】）。",
}
--永恒技实现，放置在最上方
qc__yongzhan:addLoseEffect(function(self, player, is_death)
    local room = player.room
    room:handleAddLoseSkills(player, qc__yongzhan.name, nil, false, true)
end)

qc__yongzhan:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qc__yongzhan.name) and data.from == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local skills = table.filter(player:getSkillNameList(), function(s) return Fk.skills[s]:isPlayerSkill(player) end)
    if #skills > 0 then
      for _, s in ipairs(skills) do
        player:clearSkillHistory(s)
      end
    end
  end,
})

qc__yongzhan:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qc__yongzhan.name)
  end,
  on_use = function(self, event, target, player, data)
    local count = player:getMark("@qc__yongzhan")
    if count > 0 then
      player.room:recover{
          who = player,
          num = count,
          recoverBy = player,
          skillName = qc__yongzhan.name,
      }
    end
  end,
})

return qc__yongzhan
