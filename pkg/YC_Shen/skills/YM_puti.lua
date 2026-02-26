local YM_puti = fk.CreateSkill {
  name = "YM_puti",
  anim_type = "offensive",
}

Fk:loadTranslationTable{
 ["YM_puti"] = "菩提",
 [":YM_puti"] = "你始终跳过准备阶段与判定阶段。每当场上有目标用牌时，你摸一张牌，并对用牌目标造成一点伤害。",

  ["$YM_puti1"] = "此乃天机，岂可泄露啊。",
}

YM_puti:addEffect(fk.EventPhaseChanging, {
    is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(YM_puti.name) and
      table.contains({Player.Start, Player.Judge}, data.phase) and not data.skipped
  end,
  on_use = function (self, event, target, player, data)
    data.skipped = true
  end,
})

YM_puti:addEffect(fk.CardUsing, {
    is_delay_effect = true,
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(YM_puti.name,true,true) and data.card
    end,  
    on_use = function(self, event, target, player, data)
        local room = player.room
        room:drawCards(player, 1)
        room:damage({
            from = player,
            to = data.from,
            damage = 1,
            skillName = YM_puti.name,
        })
    end,
})

  return YM_puti