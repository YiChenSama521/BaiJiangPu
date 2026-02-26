local sgd_jsdq = fk.CreateSkill({
  name = "sgd_jsdq",
  tags = { Skill.Permanent, Skill.Compulsory },
})

Fk:loadTranslationTable {
  ["sgd_jsdq"] = "据水断桥",
  [":sgd_jsdq"] = "永恒技，①你使用【杀】无次数限制，黑色【杀】额外结算一次。②当你使用【杀】指定目标后，你弃置其1+X张牌且其非锁定技失效。③你的【杀】造成伤害+X且目标减少相等的体力值上限（X为本回合使用【杀】次数）。",

  ["$sgd_jsdq1"] = "战又不战，退又不退，却是何故！",
  ["$sgd_jsdq2"] = "据桥一喝，闻者无不肝胆碎裂！",
  ["$sgd_jsdq3"] = "虎牢硝烟起，长坂水逆流！",
}

sgd_jsdq:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_jsdq.name, nil, false, true)  
end)

--①你使用【杀】无次数限制
sgd_jsdq:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return player:hasSkill(sgd_jsdq.name) and skill.trueName == "slash_skill" and card.trueName == "slash"
  end,
})
--黑色【杀】额外结算
sgd_jsdq:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(sgd_jsdq.name) and data.card and data.card.trueName == "slash" and
    data.card.color == Card.Black and player.room.current == player
  end,
  on_use = function(self, event, target, player, data)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})
--②你使用【杀】指定目标弃牌 给非锁定技失效标记
sgd_jsdq:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(sgd_jsdq.name) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:usedCardTimes("slash") + 1
    if #data.tos == 0 then return end
    for _, p in ipairs(data.tos) do
      if not p:isNude() then
        local cards = room:askToChooseCards(player, {
          target = p,
          min = x,
          max = x,
          flag = "he",
          skill_name = sgd_jsdq.name,
        })
        room:throwCard(cards, sgd_jsdq.name, p, player)
      end
      room:setPlayerMark(p, MarkEnum.UncompulsoryInvalidity, 1)
    end
  end,
})
--③你的【杀】造成伤害+X 且目标减少相等的体力值上限(X为本回合使用【杀】次数)。
sgd_jsdq:addEffect(fk.DetermineDamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgd_jsdq.name) and data.from == player and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:usedCardTimes("slash")
    data.damage = data.damage + x
    room:changeMaxHp(data.to, -data.damage)
    -- data:preventDamage()
  end,
})

return sgd_jsdq
