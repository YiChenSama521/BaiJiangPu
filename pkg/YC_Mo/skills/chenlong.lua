local chenlong = fk.CreateSkill{
  name = "YC__chenlong",
}

Fk:loadTranslationTable{
  ["YC__chenlong"] = "辰龙",
  [":YC__chenlong"] = "出牌阶段限一次，你可以失去至多2点体力，对一名其他角色造成等量伤害。若你因此进入濒死状态，你减1点体力上限。",

  ["#YC__chenlong"] = "辰龙：失去至多2点体力，对一名角色造成等量伤害",

  ["$YC__chenlong"] = "龙怒的威力，不是你所能承受的。",
}

chenlong:addEffect("active", {
  anim_type = "offensive",
  prompt = "#YC__chenlong",
  card_num = 0,
  target_num = 1,
  interaction = UI.Spin {
    from = 1,
    to = 2,
  },
  can_use = function(self, player)
    return player:usedSkillTimes(chenlong.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = self.interaction.data
    room:loseHp(player, n, chenlong.name)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = n,
        skillName = chenlong.name,
      }
    end
  end,
})
chenlong:addEffect(fk.EnterDying, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if target == player and player:usedSkillTimes("YC__chenlong", Player.HistoryPhase) > 0 and
      not player.dead then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.LoseHp)
      return e and e.data.skillName == "YC__chenlong"
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:changeMaxHp(player, -1)
  end,
})

return chenlong
