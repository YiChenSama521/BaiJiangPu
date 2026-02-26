local YM_jieyin = fk.CreateSkill {
  name = "YM_jieyin",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["YM_jieyin"] = "接引",
  ["@@YM_jieyin"] = "接引操控",
  ["#YM_jieyin"] = "接引：你可操控一名角色至你死亡。",
  [":YM_jieyin"] = "限定技，游戏开始前你可选择一名其他角色，操作目标直至你死亡。",

  ["$YM_jieyin1"] = "我在西方以慧眼相观，见东南二处有百余道红光冲天，知是有缘。",
}

YM_jieyin:addEffect(fk.GamePrepared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(YM_jieyin.name) and player:usedSkillTimes(YM_jieyin.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local selected = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      prompt = "#YM_jieyin",
      skill_name = YM_jieyin.name
    })
    if #selected ~= 0 then
      event:setCostData(self, { tos = selected })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local dat = event:getCostData(self).tos[1]
    local room = player.room
    room:setPlayerMark(dat, "@@YM_jieyin", 1)
    player:control(dat)
  end,
})

YM_jieyin:addEffect(fk.Death, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local jy = false
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@@YM_jieyin") > 0 then
        jy = true
      end
    end
    return player:hasSkill(YM_jieyin.name, true, true) and target == player and jy
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@@YM_jieyin") > 0 then
        room:setPlayerMark(p, "@@YM_jieyin", 0)
        p:control(p)
      end
    end
  end,
})

return YM_jieyin
