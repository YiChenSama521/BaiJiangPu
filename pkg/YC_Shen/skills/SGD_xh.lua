local sgd_xh = fk.CreateSkill {
  name = "sgd_xh",
  tags = { Skill.Permanent, Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["sgd_xh"] = "兴汉",
  [":sgd_xh"] = "永恒技，你的武将牌无法被替换，技能无法失去且不能被取消发动，然后你获得游戏胜利。",
}

sgd_xh:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_xh.name, nil, false, true)
end)

sgd_xh:addAcquireEffect(function(self, player, is_start)
    player.room:gameOver(player.role)
end)

return sgd_xh