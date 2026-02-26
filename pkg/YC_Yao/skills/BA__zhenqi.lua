local ba__zhenqi = fk.CreateSkill {
  name = "ba__zhenqi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["ba__zhenqi"] = "真气",
  [":ba__zhenqi"] = "锁定技，游戏开始时/每个回合开始时，你获得2/1枚“真气”，每枚“真气”可以抵挡1点伤害。当你造成伤害时，伤害增加X（X为“真气”数量）。",
  ["@ba__zhenqi"] = "真气",
}

ba__zhenqi:addEffect(fk.GameStart, {
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ba__zhenqi", 2)
  end,
})

ba__zhenqi:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__zhenqi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ba__zhenqi", 1)
  end,
})

ba__zhenqi:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__zhenqi.name) and player:getMark("@ba__zhenqi") > 0 and
    data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local count = player:getMark("@ba__zhenqi")
    local reduce = math.min(data.damage, count)
    data.damage = data.damage - reduce
    if data.damage <= 0 then
      return true
    end
  end,
})

ba__zhenqi:addEffect(fk.DetermineDamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(ba__zhenqi.name) and player:getMark("@ba__zhenqi") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player:getMark("@ba__zhenqi")
  end,
})

return ba__zhenqi
