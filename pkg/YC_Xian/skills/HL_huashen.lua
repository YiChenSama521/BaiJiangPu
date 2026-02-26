local hl_huashen = fk.CreateSkill {
  name = "hl_huashen",
  tags = {Skill.Permanent},
}

Fk:loadTranslationTable{
  ["hl_huashen"] = "化身",
  [":hl_huashen"] = "游戏开始、你的回合开始、你的回合结束、你受到伤害后，你从随机三张武将牌中选择一项技能获得。",
  ["#hl_huashen-skill"] = "化身：选择一个武将，再选择一个要获得的技能",
  ["@hl_huashen"] = "化身",
  ["$hl_huashen1"] = "大道之行，气象万千。",
  ["$hl_huashen2"] = "混元归一气，一气化三清。",
}
--黑名单
local huashen_blacklist = {
  -- imba
  "zuoci", "ol_ex__zuoci", "qyt__dianwei", "starsp__xiahoudun", "mou__wolong","o__huashen",
  -- haven't available skill
  "js__huangzhong", "liyixiejing", "olz__wangyun", "yanyan", "duanjiong", "wolongfengchu", "wuanguo", "os__wangling", "tymou__jiaxu",
}

local function Dohuashen(player)
  local room = player.room
  --get general
  local allgenerals = table.filter(room.general_pile, function (name)
    return not table.contains(huashen_blacklist, name) 
  end)
  local generals = {}
  for _ = 1, 3 do
    if #allgenerals == 0 then break end
    local g = table.remove(allgenerals, math.random(#allgenerals))
    table.insert(generals, g)
    table.removeOne(room.general_pile, g)
  end
  if #generals == 0 then return end
  local default = {}
  local skillList = {}
  for _, g in ipairs(generals) do
    local general = Fk.generals[g]
    local skills = {}
    for _, skillName in ipairs(general:getSkillNameList()) do
      table.insert(skills, skillName)
      if #default == 0 then
        default = {g, skillName}
      end
    end
    table.insert(skillList, skills)
  end
  local result = room:askToCustomDialog( player, {
    skill_name = hl_huashen.name,
    qml_path = "packages/utility/qml/ChooseSkillFromGeneralBox.qml",
    extra_data = { generals, skillList, "#hl_huashen-skill" },
  })
  if result == "" then
    if #default == 0 then return end
    result = default
  end
  local generalName, skill = table.unpack(result)
  room:setPlayerMark(player, "@ol_ex__huashen_skill", {generalName, skill})
  room:handleAddLoseSkills(player, skill)
  room:delay(500)
  room:returnToGeneralPile(generals)
end


hl_huashen:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hl_huashen.name)
  end,
  on_use = function(self, event, target, player, data)
    Dohuashen(player)
  end,
})
hl_huashen:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hl_huashen.name) and target == player
  end,
  on_use = function(self, event, target, player, data)
    Dohuashen(player)
  end,
})
hl_huashen:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hl_huashen.name) and target == player
  end,
  on_use = function(self, event, target, player, data)
    Dohuashen(player)
  end,
})
hl_huashen:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hl_huashen.name) and target == player
  end,
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  on_use = function(self, event, target, player, data)
    Dohuashen(player)
  end,
})

return hl_huashen
