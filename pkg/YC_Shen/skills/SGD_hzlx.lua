local sgd_hzlx = fk.CreateSkill {
  name = "sgd_hzlx",
  tags = { Skill.Permanent, Skill.Wake }
}

Fk:loadTranslationTable {
  ["sgd_hzlx"] = "汉祚龙兴",
  [":sgd_hzlx"] = "永恒觉醒技，当一名势力不为蜀的敌方角色死亡后，你将体力值调整为1点，获得2X点护甲，然后你获得技能【兴汉】（X为体力变化值且至少为1）。",
}

sgd_hzlx:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_hzlx.name, nil, false, true)
end)

sgd_hzlx:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_hzlx.name) and player:usedSkillTimes(sgd_hzlx.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return data.who.kingdom ~= "shu"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = math.max(math.abs(player.hp - 1), 1)
    room:setPlayerProperty(player, "hp", 1)
    room:changeShield(player, x * 2)
    room:handleAddLoseSkills(player, "sgd_xh", sgd_hzlx.name, true, true)
  end,
})

return sgd_hzlx
