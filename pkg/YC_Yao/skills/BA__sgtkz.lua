local ba__sgtkz = fk.CreateSkill {
  name = "ba__sgtkz",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable {
  ["ba__sgtkz"] = "死光头，看招！",
  [":ba__sgtkz"] = "觉醒技，当友方角色进入濒死状态后，你失去技能【兄弟同心】【智囊】【蛮力】减少6点体力上限并永久获得技能【森林之怒】。",
}

ba__sgtkz:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (target == player or not target:isEnemy(player)) and player:usedSkillTimes(ba__sgtkz.name, Player.HistoryGame) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -6)
    room:handleAddLoseSkills(player, "-ba__xiongditongxin|-ba__zhinang|-ba__manli|ba__senlinzhinu", nil, true, false)
  end,
})

return ba__sgtkz
