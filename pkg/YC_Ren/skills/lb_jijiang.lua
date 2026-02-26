local lb_jijiang = fk.CreateSkill({
  name = "lb_jijiang",
  tags = { Skill.Permanent, Skill.Lord },
})

Fk:loadTranslationTable {
    ["lb_jijiang"] = "激将",
    [":lb_jijiang"] = "持恒技，主公技，游戏开始时额外获得6枚“仁望”标记；当你需要使用或打出【杀】时，你可以令其他蜀势力角色选择是否打出一张【杀】（视为由你使用或打出）。",
    ["@jijiang-sha-turn"] = "杀数增加:",
}

lb_jijiang:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = lb_jijiang.name
    return c
  end,

  before_use = function(self, player, use)
    local room = player.room
    if use.tos then
      room:doIndicate(player.id, table.map(use.tos, Util.IdMapper))
    end

    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "shu" then
        local respond = room:askToResponse(p, {
          skill_name = lb_jijiang.name,
          pattern = "slash",
          prompt = "#jijiang-ask:" .. player.id,
          cancelable = true,
        })
        if respond then
          respond.skipDrop = true
          room:responseCard(respond)

          use.card = respond.card
          return
        end
      end
    end

    room:setPlayerMark(player, "lb_jijiang_failed-phase", 1)
    return lb_jijiang.name
  end,
  after_use = function(self, player, use)
    local room = player.room
    room:addPlayerMark(player, MarkEnum.SlashResidue .. "-turn", 1)
    room:addPlayerMark(player, "@jijiang-sha-turn", 1)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("lb_jijiang_failed-phase") == 0 and
        table.find(Fk:currentRoom().alive_players, function(p)
          return p.kingdom == "shu" and p ~= player
        end)
  end,
  enabled_at_response = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function(p)
      return p.kingdom == "shu" and p ~= player
    end)
  end,
})

lb_jijiang:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(lb_jijiang.name) == true then
      room:addPlayerMark(player, "@lb_rende_cards", 6)
    end
  end,
}
)

return lb_jijiang
