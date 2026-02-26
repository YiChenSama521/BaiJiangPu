local YM_shengwei = fk.CreateSkill {
  name = "YM_shengwei",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["YM_shengwei"] = "圣威",
  ["@shengwei-turn"] = "圣威",
  ["@@lua_louyi"] = "蝼蚁",
  [":YM_shengwei"] = "锁定技，除你外所有角色于回合内出牌次数超过7张时你结束其回合" ..
  "<br>你造成的伤害结算开始前，令目标获得“蝼蚁”标记直到本次伤害结算结束，有“蝼蚁”标记的角色发动技能时取消之，且你对其造成的伤害至少为其体力上限。",
  ["$YM_shengwei1"] = "四圣汇诛仙，分辩忠与奸。",
}

YM_shengwei:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(YM_shengwei.name) and target and target ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(target, "@shengwei-turn", 1)
    if target:getMark("@shengwei-turn") >= 7 then
      room:endTurn()
    end
  end,
})

YM_shengwei:addEffect(fk.PreDamage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(YM_shengwei.name) and data.to ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(data.to, "@@lua_louyi", 1)
    data.damage = math.max(data.damage, data.to.maxHp)
  end,
})

YM_shengwei:addEffect(fk.DamageFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(YM_shengwei.name, true, true) and data.to:getMark("@@lua_louyi") == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(data.to, "@@lua_louyi", 0)
  end,
})

YM_shengwei:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and player:hasSkill(YM_shengwei.name, true, true) and target:getMark("@@lua_louyi") == 1 and data.skill:isPlayerSkill(target)
    and target:hasSkill(data.skill:getSkeleton().name, true, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      e:shutdown()
    end
  end,
})


return YM_shengwei
