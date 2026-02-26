local YAN__qianglue = fk.CreateSkill({name = "YAN__qianglue"})

Fk:loadTranslationTable {
    ["YAN__qianglue"] = "抢掠",
    [":YAN__qianglue"] = "你对一名角色造成伤害时，你可对其使用一张【顺手牵羊】。",
    ["#YAN__qianglue"] = "抢掠：你可以对 %src 使用一张【顺手牵羊】。",
    ["@YAN__qianglue"] = "抢掠",
}

YAN__qianglue:addEffect(fk.DamageCaused,{
    can_trigger = function (self, event, target, player, data)
        return player:hasSkill(YAN__qianglue.name) and data.from == player and player:isAlive() == true and player:isKongcheng() == false
    end,
  on_use = function(self, event, target, player, data)
    local room = player.room
      -- 询问使用顺手牵羊
      local to = data.to
      room:useVirtualCard("snatch", nil, player, to, YAN__qianglue.name, true)
  end,
})

return YAN__qianglue
