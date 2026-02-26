local qc__zhanli = fk.CreateSkill({
    name = "qc__zhanli",
    tags = { Skill.Permanent, Skill.Compulsory },
})
Fk:loadTranslationTable{
    ["qc__zhanli"] = "战力",
    [":qc__zhanli"] = "永恒技，游戏开始时，你令所有角色获得<a href=':qc__zhanli-zhanxin'>【战心】</a>以及 1点【战力值】，你额外获得2点。",
    [":qc__zhanli-zhanxin"] = "战心：持恒技，你每造成4点伤害后，你获得1点【战力值】。你造成的伤害+2X，受到的伤害-X（X为你的【战力值】）。",
    ["@qc__zhanli"] = "战力值",
}
--永恒技实现，放置在最上方
qc__zhanli:addLoseEffect(function(self, player, is_death)
    local room = player.room
    room:handleAddLoseSkills(player, qc__zhanli.name, nil, false, true)
end)

qc__zhanli:addAcquireEffect(function(self, player)
    local room = player.room
    local players = room:getAllPlayers()
    for i = 1, #players, 1 do
      local p = players[i]
      room:handleAddLoseSkills(p, "qc__zhanxin", qc__zhanli.name, false, true)
    end
end)

qc__zhanli:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qc__zhanli.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local players = room:getAllPlayers()
    for i = 1, #players, 1 do
      local p = players[i]
      room:handleAddLoseSkills(p, "qc__zhanxin", qc__zhanli.name, false, true)
      room:setPlayerMark(p, "@qc__zhanli", 1)
    end
    room:addPlayerMark(player, "@qc__zhanli", 2)
  end,
})

return qc__zhanli
