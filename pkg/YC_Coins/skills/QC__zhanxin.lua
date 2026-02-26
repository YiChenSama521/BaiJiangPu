local qc__zhanxin = fk.CreateSkill({
    name = "qc__zhanxin",
    tags = { Skill.Permanent },
})
Fk:loadTranslationTable{
    ["qc__zhanxin"] = "战心",
    [":qc__zhanxin"] = "持恒技，你每造成4点伤害后，你获得1点【战力值】。你造成的伤害+2X，受到的伤害-X（X为你的【战力值】）。",
    ["@qc__zhanli"] = "战力值",
}

qc__zhanxin:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.from == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "zhanlidamage", data.damage)
    while player:getMark("zhanlidamage") >= 4 do
      room:addPlayerMark(player, "@qc__zhanli", 1)
      room:removePlayerMark(player, "zhanlidamage", 4)
    end
  end,
})

qc__zhanxin:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
      return target == player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
      data.damage = data.damage + (player:getMark("@qc__zhanli") * 2)
  end,
})

qc__zhanxin:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - player:getMark("@qc__zhanli")
  end,
})

return qc__zhanxin
