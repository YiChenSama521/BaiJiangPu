local sishe = fk.CreateSkill{
  name = "YC__sishe",
}

Fk:loadTranslationTable{
  ["YC__sishe"] = "巳蛇",
  [":YC__sishe"] = "当你受到伤害后，你可以对伤害来源造成等量伤害。",

  ["#YC__sishe-invoke"] = "巳蛇：是否对 %dest 造成%arg点伤害？",

  ["$YC__sishe"] = "伤我者，一一奉还。",
}

sishe:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(sishe.name) and data.from and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = sishe.name,
      prompt = "#YC__sishe-invoke::"..data.from.id..":"..data.damage,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = data.from,
      damage = data.damage,
      skillName = sishe.name,
    }
  end,
})

return sishe
