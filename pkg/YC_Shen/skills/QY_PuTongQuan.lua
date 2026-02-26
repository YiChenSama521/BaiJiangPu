local putongquan = fk.CreateSkill({
  name = "putongquan",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable {
  ["putongquan"] = "普通拳",
  [":putongquan"] = "锁定技，你使用【杀】对其他角色造成伤害时，若其体力值上限低于18，可以将伤害调整为1~18点；若其体力值上限大于等于18，其直接死亡。",
  ["#putongquan__active"] = "普通拳",
  ["@putongquan_record"] = "普通拳增伤",
  ["putongquan__changedamage"] = "普通拳：更改此杀伤害为对应值！",
}

putongquan:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(putongquan.name) and data.card and data.card.trueName == "slash" and
        data.to.maxHp <= 18
  end,
  on_cost = function(self, event, target, player, data)
    local suc, dat = player.room:askToUseActiveSkill(player,
      { skill_name = "#putongquan__active", cancelable = false, prompt = "putongquan__changedamage" })
    if suc and dat then
      event:setCostData(self, { num = dat.interaction })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local dat = event:getCostData(self).num
    data:changeDamage(dat - data.damage)
  end,
})

putongquan:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(putongquan.name) and target and target == player and data.card.trueName == "slash" and
        table.find(data.tos, function(p) return p.maxHp >= 18 end)
  end,
  on_use = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 17
    for _, v in ipairs(data.tos) do
      if v.maxHp >= 18 then
        player.room:killPlayer({
          who = v,
          skillName = putongquan.name,
        })
      end
    end
  end,
})

return putongquan
