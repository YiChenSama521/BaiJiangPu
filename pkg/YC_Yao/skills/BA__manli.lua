local ba__manli = fk.CreateSkill {
  name = "ba__manli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["ba__manli"] = "蛮力",
  [":ba__manli"] = "锁定技，你造成伤害增加X，且当你对目标造成伤害后，随机弃置其X张牌；你摸Y张牌（X为你当前体力值，Y为已损失体力值）。",
}

ba__manli:addEffect(fk.DetermineDamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(self) and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player.hp
  end,
})

ba__manli:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(self) and data.card and not data.to:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = data.to
    local X = player.hp
    local Y = player.maxHp - player.hp
    if not tos:isNude() then
      room:askToDiscard(tos, {
        min_num = X,
        max_num = X,
        cancelable = false,
        include_equip = true,
        skill_name = self.name,
      })
    end

    if Y > 0 then
      player:drawCards(Y, self.name)
    end
  end,
})

return ba__manli
