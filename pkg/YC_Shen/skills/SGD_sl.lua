local sgd_sl = fk.CreateSkill({
  name = "sgd_sl",
  tags = { Skill.Permanent, Skill.Compulsory },
})

Fk:loadTranslationTable{
    ["sgd_sl"] = "神临",
    [":sgd_sl"] = "游戏开始时，你获得一个额外的回合。",
}

sgd_sl:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_sl.name, nil, false, true)
end)

sgd_sl:addEffect(fk.GameStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_sl.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:sendLog{
      type = "#TriggerSkill",
      from = player.id,
      arg = sgd_sl.name
    }
    player:gainAnExtraTurn(false)
  end,
})

return sgd_sl
