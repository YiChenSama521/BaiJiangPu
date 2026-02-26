local maotu = fk.CreateSkill{
  name = "YC__maotu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["YC__maotu"] = "卯兔",
  [":YC__maotu"] = "锁定技，当有角色濒死结算后，直到你下回合开始，你不能成为体力值不小于你的角色使用牌的目标。",

  ["@@YC__maotu"] = "卯兔",

  ["$YC__maotu"] = "想抓到我？不可能！",
}

maotu:addEffect(fk.AfterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(maotu.name) and player:getMark("@@YC__maotu") == 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@YC__maotu", 1)
  end,
})
maotu:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@YC__maotu") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@YC__maotu", 0)
  end,
})
maotu:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return to:getMark("@@YC__maotu") > 0 and card and from and from.hp >= to.hp
  end,
})

return maotu
