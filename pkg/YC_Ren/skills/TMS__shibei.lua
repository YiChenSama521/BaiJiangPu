local TMS__shibei = fk.CreateSkill {
  name = "TMS__shibei",
  tags = {Skill.Compulsory},
}
Fk:loadTranslationTable{
  ["TMS__shibei"] = "失北",
  [":TMS__shibei"] = "锁定技，当你在一个回合首次受到伤害时，你恢复一点体力，你在本回合第二次受到伤害时，你失去一点体力，然后重置此技能。",

  ["$TMS__shibei1"] = "速砍吾项上头颅，誓死不委身背主！",
  ["$TMS__shibei2"] = "吾主虽庸尽忠胆，不似曹氏窃汉贼！",
}

TMS__shibei:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(self.name) and not data.isVirtualDMG
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.isVirtualDMG then return end
    local events = room.logic:getActualDamageEvents(999, function(e)
      return e.data.to == player and not e.data.isVirtualDMG
    end) or 0
    if #events % 2 == 0 then
      room:notifySkillInvoked(player, TMS__shibei.name, "defensive")
      if player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          skillName = TMS__shibei.name,
        }
      end
    else
      room:notifySkillInvoked(player, TMS__shibei.name, "negative")
      room:loseHp(player, 1, TMS__shibei.name)
    end
  end,
})

return TMS__shibei
