local ba__senlinzhinu = fk.CreateSkill {
  name = "ba__senlinzhinu",
  tags = { Skill.Compulsory, Skill.Permanent },
}

Fk:loadTranslationTable {
  ["ba__senlinzhinu"] = "森林之怒",
  [":ba__senlinzhinu"] = "永恒技，你使用牌无距离和次数限制，造成伤害时，伤害增加X（X为你的体力值上限）。<br/>"..
  "当你获得此技能时，你开启<a href= ':ba__gouxiongling'><font color = '#810080'>【狗熊岭】<font></a>光环。",
  ["ba__gouxiongling"] = "狗熊岭",
  [":ba__gouxiongling"] = "除熊大熊二外所有角色受到伤害翻倍，体力值变动时弃置一半手牌。",
  ["@[:]ba__gouxiongling"] = "",
}
--获得技能设置banner
ba__senlinzhinu:addAcquireEffect(function(self, player, is_start)
  local room = player.room
  room:setBanner("@[:]ba__gouxiongling", "ba__gouxiongling")
end)
--永恒技
ba__senlinzhinu:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, ba__senlinzhinu.name, nil, false, true)
end)
--使用牌无距离和次数限制
ba__senlinzhinu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return player:hasSkill(ba__senlinzhinu.name)
  end,
  bypass_distances = function(self, player, skill, scope, card)
    return player:hasSkill(ba__senlinzhinu.name)
  end,
})
--造成伤害时，伤害增加X（X为你的体力值上限）
ba__senlinzhinu:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__senlinzhinu.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player.maxHp
  end,
})
--除熊大熊二外所有角色受到伤害翻倍
ba__senlinzhinu:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player.room:getBanner("@[:]ba__gouxiongling") then
      return player.general ~= "ba__xiong" and player.deputyGeneral ~= "ba__xiong"
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage * 2
  end
  })
--体力值变动时弃置一半手牌
ba__senlinzhinu:addEffect(fk.HpChanged, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player.room:getBanner("@[:]ba__gouxiongling") then
    return player.general ~= "ba__xiong" and player.deputyGeneral ~= "ba__xiong" and not target:isKongcheng()
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local count = math.floor(#target:getCardIds("h") / 2)
    if count > 0 then
      player.room:askToDiscard(target, {
        max_num = count,
        min_num = count,
        cancelable = false,
        include_equip = false,
        skill_name = ba__senlinzhinu.name,
      })
  end
  end,
})

return ba__senlinzhinu
