local tianqimofang = fk.CreateSkill {
  name = "ba__tianqimofang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["ba__tianqimofang"] = "天气魔方",
  [":ba__tianqimofang"] = "锁定技，每轮开始，场上获得一种<a href= ':ba__tianqimofang_weather'>【天气】</a>（不重复），六大天气集齐时杀死所有敌方角色。",

  ["@[:]ba__tianqimofang"] = "天气魔方",

  [":ba__tianqimofang_weather"] = "风：友方的攻击距离无限，使用牌无距离次数限制，所有敌方角色使用牌都有50%概率失效；" ..
      "<br/>乌云：所有敌方角色使用的基本牌无效；" ..
      "<br/>太阳：每个回合开始时，对所有敌方角色造成其体力上限10%的火焰伤害（至少为5），且所有敌方角色受到的火焰伤害翻倍；" ..
      "<br/>闪电：每个回合结束时所有敌方角色被横置；每个回合开始时，所有敌方角色进行一次50%概率的【闪电】判定；" ..
      "<br/>雷：每轮开始时，敌方体力值上限最高的角色体力值上限调整至1；" ..
      "<br/>冰：所有敌方角色的非锁定技无效；",
  ["#ba__tianqimofang_weather"] = "%from 发动【天气魔方】，获得天气：【%arg】",
  ["#ba__tianqimofang_complete"] = "%from 集齐了所有天气，【天气魔方】发动！",
  ["ba__wind"] = "风",
  [":ba__wind"] = "友方的攻击距离无限，使用牌无距离次数限制，所有敌方角色使用牌都有50%概率失效",
  ["ba__clouds"] = "乌云",
  [":ba__clouds"] = "所有敌方角色使用的基本牌无效",
  ["ba__sun"] = "太阳",
  [":ba__sun"] = "每个回合开始时，对所有敌方角色造成其体力上限10%的火焰伤害（至少为5），且所有敌方角色受到的火焰伤害翻倍",
  ["ba__lightning"] = "闪电",
  [":ba__lightning"] = "每个回合结束时所有敌方角色被横置；每个回合开始时，所有敌方角色进行一次50%概率的【闪电】判定",
  ["ba__thunder"] = "雷",
  [":ba__thunder"] = "每轮开始时，敌方体力值上限最高的角色体力值上限调整至1",
  ["ba__ice"] = "冰",
  [":ba__ice"] = "所有敌方角色的非锁定技无效",
}

local Weathers = { "ba__wind", "ba__clouds", "ba__sun", "ba__lightning", "ba__thunder", "ba__ice" }

local function isSkillActive(player)
  if not player:hasSkill(tianqimofang.name) then return false end
  if player.id > 0 then
    for _, p in ipairs(Fk:currentRoom().players) do
      if p.id <= 0 and p:hasSkill(tianqimofang.name, true, true) then
        return false
      end
    end
  end
  return true
end

tianqimofang:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return isSkillActive(player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner("@[:]ba__tianqimofang") or {}
    local weathers = table.filter(Weathers, function(w)
      return not table.contains(banner, w)
    end)
    local weather = table.random(weathers)
    table.insertIfNeed(banner, weather)
    room:setBanner("@[:]ba__tianqimofang", banner)
    room:sendLog {
      type = "#ba__tianqimofang_weather",
      from = player.id,
      arg = Fk:translate(weather),
      toast = true,
    }
    if #weathers <= 1 then
      local tos = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
      if #tos == 0 then return end
      room:sortByAction(tos)
      for _, p in ipairs(tos) do
        room:killPlayer({ who = p, skillName = tianqimofang.name, })
      end
    end
    -- 雷：每轮开始时，敌方体力值上限最高的角色体力值上限调整至1
    if table.contains(banner, "ba__thunder") then
      local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
      if #enemies > 0 then
        table.sort(enemies, function(a, b) return a.maxHp > b.maxHp end)
        local maxHp = enemies[1].maxHp
        for _, tar in ipairs(enemies) do
          if tar.maxHp == maxHp then
            room:setPlayerProperty(tar, "hp", 1)
            room:setPlayerProperty(tar, "maxHp", 1)
          else
            break
          end
        end
      end
    end
  end
})
-- 乌云：所有敌方角色使用的基本牌无效；
-- 风：所有敌方角色使用牌都有50%概率失效；
tianqimofang:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if isSkillActive(player) and target:isEnemy(player) and data.card then
      local banner = player.room:getBanner("@[:]ba__tianqimofang") or {}
      return (table.contains(banner, "ba__clouds") and data.card.type == Card.TypeBasic)
          or (table.contains(banner, "ba__wind") and math.random(1, 100) <= 50)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.nullifiedTargets = table.simpleClone(player.room.players)
  end,
})
-- 太阳：回合开始时，对所有敌方角色造成其体力上限10%的火焰伤害（至少为5）
-- 闪电：回合开始时，所有敌方角色进行一次50%概率的【闪电】判定
tianqimofang:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target and isSkillActive(player) then
      local banner = player.room:getBanner("@[:]ba__tianqimofang") or {}
      return table.contains(banner, "ba__sun") or table.contains(banner, "ba__lightning")
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner("@[:]ba__tianqimofang") or {}
    local tos = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    if #tos == 0 then return end
    room:sortByAction(tos)
    if table.contains(banner, "ba__sun") then
      for _, p in ipairs(tos) do
        local damage = math.max(5, math.floor(p.maxHp * 0.1))
        room:damage { to = p, damage = damage, damageType = fk.FireDamage, }
      end
    end
    tos = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    if #tos == 0 then return end
    room:sortByAction(tos)
    if table.contains(banner, "ba__lightning") then
      for _, p in ipairs(tos) do
        if math.random(1, 100) <= 50 then
          room:damage { to = p, damage = 3, damageType = fk.ThunderDamage, }
        end
      end
    end
  end,
})
-- 风：友方的攻击距离无限，使用牌无距离次数限制
tianqimofang:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    local room = Fk:currentRoom()
    local banner = room:getBanner("@[:]ba__tianqimofang") or {}
    return #banner > 0 and table.contains(banner, "ba__wind") and player and table.find(room.players, function(p)
      return isSkillActive(p) and p:isFriend(player)
    end)
  end,
  bypass_distances = function(self, player, skill, card, to)
    local room = Fk:currentRoom()
    local banner = room:getBanner("@[:]ba__tianqimofang") or {}
    return #banner > 0 and table.contains(banner, "ba__wind") and player and table.find(room.players, function(p)
      return isSkillActive(p) and p:isFriend(player)
    end)
  end,
})
-- 太阳：所有敌方角色受到的火焰伤害翻倍
tianqimofang:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target and isSkillActive(player) and target:isEnemy(player) and data.damageType == fk.FireDamage then
      local banner = player.room:getBanner("@[:]ba__tianqimofang") or {}
      return table.contains(banner, "ba__sun")
    end
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage * 2
  end,
})
-- 闪电：回合结束时所有敌方角色被横置
tianqimofang:addEffect(fk.TurnEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target and isSkillActive(player) then
      local banner = player.room:getBanner("@[:]ba__tianqimofang") or {}
      return table.contains(banner, "ba__lightning")
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    if #tos == 0 then return end
    room:sortByAction(tos)
    for _, p in ipairs(tos) do
      p:setChainState(true)
    end
  end,
})
-- 冰：所有敌方角色的非锁定技无效
tianqimofang:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    local room = Fk:currentRoom()
    local banner = room:getBanner("@[:]ba__tianqimofang") or {}
    if #banner > 0 and table.contains(banner, "ba__ice") then
      return skill:isPlayerSkill(from) and not skill:hasTag(Skill.Compulsory) and table.find(room.players, function(p)
        return isSkillActive(p) and p:isEnemy(from)
      end)
    end
  end,
})

return tianqimofang
