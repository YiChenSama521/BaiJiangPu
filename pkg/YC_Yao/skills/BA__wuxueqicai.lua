local ba__wuxueqicai = fk.CreateSkill {
  name = "ba__wuxueqicai",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
    ["ba__wuxueqicai"] = "武学奇才",
    [":ba__wuxueqicai"] = "持恒技，当你对其他角色造成伤害后，你随机复制其一个非锁定技，并获得X层“领悟”（X为造成伤害）。当你拥有18层领悟时，你使用牌无法被响应，且你获得所有敌方角色的非锁定技。",
    ["@ba__lingwu"] = "领悟",
}

ba__wuxueqicai:addEffect(fk.DamageFinished, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and data.to ~= player and player:hasSkill(ba__wuxueqicai.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local victim = data.to
    -- 随机复制其一个非锁定技
    local skills = table.filter(victim:getSkillNameList(), function(name)
      local skill = Fk.skills[name]
      return skill and not skill:hasTag(Skill.Compulsory) and name ~= ba__wuxueqicai.name
    end)
    if #skills > 0 then
      local skillName = skills[math.random(1, #skills)]
      if not player:hasSkill(skillName, true) then
        room:handleAddLoseSkills(player, skillName, nil, true, false)
      end
    end
    -- 获得X层“领悟”
    room:addPlayerMark(player, "@ba__lingwu", data.damage)
  end,
})

ba__wuxueqicai:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__wuxueqicai.name) and player:getMark("@ba__lingwu") >= 18
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 当拥有18层领悟时，获得所有敌方角色的非锁定技
      local enemies = table.filter(room:getOtherPlayers(player), function(p) return player:isEnemy(p) end)
      local all_skills = {}
      for _, p in ipairs(enemies) do
        local p_skills = table.filter(p:getSkillNameList(), function(name)
          local skill = Fk.skills[name]
          return skill and not skill:hasTag(Skill.Compulsory) and name ~= ba__wuxueqicai.name
        end)
        for _, s in ipairs(p_skills) do
          if not player:hasSkill(s, true) and not table.contains(all_skills, s) then
            table.insert(all_skills, s)
          end
        end
      end
      if #all_skills > 0 then
        room:handleAddLoseSkills(player, table.concat(all_skills, "|"), nil, true, false)
      end
  end,
})



return ba__wuxueqicai