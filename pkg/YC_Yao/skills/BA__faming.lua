local ba__faming = fk.CreateSkill {
  name = "ba__faming",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ba__faming"] = "发明",
  [":ba__faming"] = "锁定技，当你受到伤害后/回合结束时，随机发明一样<a href=':ba__faming_daoju'>【道具】<a>。",
  [":ba__faming_daoju"] = "拜拜机：使伤害来源/你选择一名玩家随机休整1~12轮数；"..
      "<br/>超级无敌美食基因枪：伤害来源获得“美食”标记/当你对其他角色造成伤害后，其获得“美食”标记；（拥有“美食”标记的角色受到伤害时立即死亡）"..
      "<br/>无敌钢甲：你变身为钢甲形态，使用【杀】改为指定所有敌方角色，且造成伤害翻倍；受到3次雷电伤害解除变身；"..
      "<br/>缩小电筒：随机一名敌方角色造成伤害固定为1，受到伤害翻倍；"..
      "<br/>阴阳离子球：对所有敌方角色造成自己当前体力值点伤害；"..
      "<br/>隐形药水：你获得一轮无敌；",
  ["#ba__faming_invent"] = "%from 发明了道具：【%arg】",
  ["ba__BBM"] = "拜拜机",
  ["#ba__faming-BBM-choose"] = "发明-拜拜机：请选择一名角色休整",
  ["ba__SIFGG"] = "超级无敌美食基因枪",
  ["@@ba__SIFGG"] = "超级无敌美食基因枪",
  ["ba__InfSA"] = "无敌钢甲",
  ["ba__STF"] = "缩小电筒",
  ["ba__ACS"] = "阴阳离子球",
  ["ba__InvPotion"] = "隐形药水",
  ["@@ba__faming_food"] = "美食",
  ["@@ba__faming_steelarmor"] = "钢甲",
  ["@@ba__faming_shrink"] = "缩小",
  ["@@ba__faming_inv-round"] = "隐形",
  ["@ba__InfSA_hp"] = "钢甲耐久",
}

local Items = { "ba__BBM", "ba__SIFGG", "ba__InfSA", "ba__STF", "ba__ACS", "ba__InvPotion" }


--- 发明道具
---@param player ServerPlayer
---@param source? ServerPlayer
local doInvent = function(player, source)
  local room = player.room
  local item = table.random(Items)
  room:sendLog {
    type = "#ba__faming_invent",
    from = player.id,
    arg = Fk:translate(item),
    toast = true,
  }

-- 拜拜机：使伤害来源/你选择一名玩家随机休整1~12轮数；
  if item == "ba__BBM" then
    local target = nil
    if player.id > 0 then
      local choices = room:askToChoosePlayers(player, {
        targets = room:getAlivePlayers(),
        min_num = 1,
        max_num = 1,
        skill_name = ba__faming.name,
        prompt = "#ba__faming-BBM-choose",
        cancelable = true,
      })
      target = choices[1]
      -- 人机逻辑：优先选伤害来源敌人，其次随机敌人
    elseif player:getMark("@ControledBy") == 0 then
      if source and source:isAlive() and player:isEnemy(source) then
        target = source
      else
        local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
        target = #enemies > 0 and table.random(enemies) or table.random(room:getAlivePlayers())
      end
    end
    if target then
      room:killPlayer { who = target, skillName = ba__faming.name }
      room:setPlayerProperty(target, "rest", math.random(1, 12))
    end

  elseif item == "ba__SIFGG" then
    -- 超级无敌美食基因枪：开启道具状态
    room:setPlayerMark(player, "@@ba__SIFGG", 1)
  elseif item == "ba__InfSA" then
    -- 无敌钢甲：开启道具状态，3次雷伤解除
    player.general = "ba__lang_1"
    room:broadcastProperty(player, "general")
    room:setPlayerMark(player, "@@ba__faming_steelarmor", 1)
    room:setPlayerMark(player, "@ba__InfSA_hp", 3)
  elseif item == "ba__STF" then
    -- 缩小电筒：随机一名敌方角色获得缩小标记
    local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    if #enemies > 0 then
      local tos = table.random(enemies)
      room:setPlayerMark(tos, "@@ba__faming_shrink", 1)
    end
  elseif item == "ba__ACS" then
    -- 阴阳离子球：对所有敌方角色造成当前体力值点伤害
    local damage_yylzq = player.hp
    local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    room:sortByAction(enemies)
    for _, p in ipairs(enemies) do
      room:damage { from = player, to = p, damage = damage_yylzq, skillName = ba__faming.name }
    end
  elseif item == "ba__InvPotion" then
    -- 隐形药水：一轮无敌
    room:setPlayerMark(player, "@@ba__faming_inv-round", 1)
  end
end

ba__faming:addEffect(fk.Damaged, {
  priority = 1,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ba__faming.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    doInvent(player, data.from)
  end,
})

ba__faming:addEffect(fk.TurnEnd, {
  priority = 1,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    doInvent(player)
  end,
})

-- 1. 超级无敌美食基因枪：给标记逻辑
ba__faming:addEffect(fk.Damaged, {
  priority = 2,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@ba__SIFGG") > 0 and data.from and not data.from.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(data.from, "@@ba__faming_food", 1)
    player.room:setPlayerMark(player, "@@ba__SIFGG", 0)
  end,
})

ba__faming:addEffect(fk.Damage, {
  priority = 3,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@ba__SIFGG") > 0 and data.to and not data.to.dead and data.from == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@@ba__faming_food", 1)
    player.room:setPlayerMark(player, "@@ba__SIFGG", 0)
  end,
})

-- 2. 各种伤害干预逻辑 (美食、无敌、缩小、隐形)
ba__faming:addEffect(fk.DetermineDamageInflicted, {
  priority = 999,
  can_trigger = function(self, event, target, player, data)
    -- 美食：即死
    if target:getMark("@@ba__faming_food") > 0 then return true end
    -- 隐形：无敌
    if target:getMark("@@ba__faming_inv-round") > 0 then return true end
    -- 缩小：受到伤害翻倍
    if (data.from and data.from:getMark("@@ba__faming_shrink") > 0) or target:getMark("@@ba__faming_shrink") > 0 then return true end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 美食标记即死
    if target:getMark("@@ba__faming_food") > 0 then
      room:killPlayer { who = target, skillName = ba__faming.name }
      return true
    end
    -- 隐形药水无敌
    if target:getMark("@@ba__faming_inv-round") > 0 then
      data:preventDamage()
      return false
    end
    if target:getMark("@@ba__faming_shrink") > 0 then
      data.damage = data.damage * 2
    end
  end,
})

-- 3. 无敌钢甲：雷伤解除逻辑
ba__faming:addEffect(fk.Damaged, {
  priority = 3,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@ba__faming_steelarmor") > 0 and data.damageType == fk.ThunderDamage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@ba__InfSA_hp") - 1
    if count <= 0 then
      room:setPlayerMark(player, "@@ba__faming_steelarmor", 0)
      room:setPlayerMark(player, "@ba__InfSA_hp", 0)
      player.general = "ba__lang"
      room:broadcastProperty(player, "general")
    else
      room:addPlayerMark(player, "@ba__InfSA_hp", -1)
    end
  end,
})
-- 5. 无敌钢甲：杀指定所有敌方
ba__faming:addEffect(fk.AfterCardTargetDeclared, {
  priority = 4,
  can_refresh = function(self, event, target, player, data)
    if target == player and player:getMark("@@ba__faming_steelarmor") > 0 and data.card and data.card.name == "slash" then
      return table.find(player.room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    end
  end,
  on_cost = Util.TrueFunc,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
    if #enemies > 1 then
      data.tos = enemies
      room:notifySkillInvoked(player, self.name, "offensive")
    end
  end,
})
-- 6. 缩小：造成为1
ba__faming:addEffect(fk.DetermineDamageCaused, {
  priority = 5,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@ba__faming_shrink") > 0 and target == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = 1
    player.room:setPlayerMark(player, "@@ba__faming_shrink", 0)
  end,
})

return ba__faming
