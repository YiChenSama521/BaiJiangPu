local lb_jishan = fk.CreateSkill { name = "lb_jishan", }

Fk:loadTranslationTable {
  ["lb_jishan"] = "积善",
  [":lb_jishan"] = "每回合各限一次：当一名角色受到伤害时，你可以失去1点体力防止此伤害，然后你与其各摸一张牌；当你造成伤害后，你可以令一名你对其发动过【积善】的角色回复1点体力。",
  ["lb_jishan_record"] = "积善标记",
  ["#lb_jishan-choose"] = "积善选择",
  ["#lb_jishan-invoke"] = "积善：你可以失去1点体力防止 %dest 受到的伤害，并与其各摸一张牌",
}

lb_jishan:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lb_jishan.name) and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
          skill_name = lb_jishan.name,
          prompt = "#lb_jishan-invoke::" .. target.id,
        }) then
      event:setCostData(self, { tos = { target } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    room:addTableMarkIfNeed(player, "lb_jishan_record", target.id)
    room:loseHp(player, 1, lb_jishan.name)
    if not player.dead then
      player:drawCards(1, lb_jishan.name)
    end
    if not target.dead then
      target:drawCards(1, lb_jishan.name)
    end
  end,
})

lb_jishan:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lb_jishan.name) and
        player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
        table.find(player.room.alive_players, function(to)
          return table.contains(player:getTableMark("lb_jishan_record"), to.id) and to:isWounded() and
              table.every(player.room.alive_players, function(p)
                return p.hp >= to.hp
              end)
        end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(to)
      return table.contains(player:getTableMark("lb_jishan_record"), to.id) and to:isWounded() and
          table.every(room.alive_players, function(p)
            return p.hp >= to.hp
          end)
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#lb_jishan-choose",
      skill_name = lb_jishan.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover {
      who = event:getCostData(self).tos[1],
      num = 1,
      recoverBy = player,
      skillName = lb_jishan.name,
    }
  end,
})

return lb_jishan
