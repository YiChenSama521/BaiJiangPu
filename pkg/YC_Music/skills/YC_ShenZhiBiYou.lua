local functions = require "packages.BaiJiangPu.functions"

local YC_ShenZhiBiYou = fk.CreateSkill{
  name = "YC_ShenZhiBiYou",
  tags = { Skill.Compulsory , Skill.Permanent },
}
local protectedGenerals = { "shen__wuhushangjiang", "shen__yaoqianshu" }

YC_ShenZhiBiYou:addEffect(fk.GamePrepared, {
  mute = true,
  global = true,
  priority = 999999999,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return table.contains(protectedGenerals, player.general) or table.contains(protectedGenerals, player.deputyGeneral) or player:getMark("@@ShenZhiBiYou") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("@@ShenZhiBiYou") == 0 then
      room:setPlayerMark(player, "@@ShenZhiBiYou", 1)
    end
    if table.contains(protectedGenerals, player.general) then
      room:setPlayerMark(player, "#@original_general", player.general)
    end
    if player.deputyGeneral and table.contains(protectedGenerals, player.deputyGeneral) then
      room:setPlayerMark(player, "#@original_deputy", player.deputyGeneral)
    end
  end,
})

YC_ShenZhiBiYou:addEffect(fk.AfterSkillEffect, {
  mute = true,
  global = true,
  priority = 203600,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if data.skill.name ~= self.name then
      if table.contains(protectedGenerals, player.general) or table.contains(protectedGenerals, player.deputyGeneral) or player:getMark("@@ShenZhiBiYou") > 0 then
        if player:getMark("@@ShenZhiBiYou") > 0 then
          local general = Fk.generals[player.general]
          if general then
            for _, skillName in ipairs(general:getSkillNameList()) do
              if not player:hasSkill(skillName, true, true) then
                return true
              end
            end
          end
          if player.deputyGeneral then
            local deputy = Fk.generals[player.deputyGeneral]
            if deputy then
              for _, skillName in ipairs(deputy:getSkillNameList()) do
                if not player:hasSkill(skillName, true, true) then
                  return true
                end
              end
            end
          end
        end
        local generalToCheck = nil
        if table.contains(protectedGenerals, player.general) then
          generalToCheck = Fk.generals[player.general]
        elseif table.contains(protectedGenerals, player.deputyGeneral) then
          generalToCheck = Fk.generals[player.deputyGeneral]
        end
        if generalToCheck then
          for _, skillName in ipairs(generalToCheck:getSkillNameList()) do
            if not table.find(player.player_skills, function(skill)
                  return skill.name == skillName
                end) then
              return true
            end
          end
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generalToCheck = nil
    if table.contains(protectedGenerals, player.general) then
      generalToCheck = Fk.generals[player.general]
    elseif table.contains(protectedGenerals, player.deputyGeneral) then
      generalToCheck = Fk.generals[player.deputyGeneral]
    end
    if player:getMark("@@ShenZhiBiYou") > 0 then
      local general = Fk.generals[player.general]
      if general then
        for _, skillName in ipairs(general:getSkillNameList()) do
          if not player:hasSkill(skillName, true, true) then
            room:notifySkillInvoked(player, self.name, "defensive")
            room:handleAddLoseSkills(player, skillName)
          end
        end
      end
      if player.deputyGeneral then
        local deputy = Fk.generals[player.deputyGeneral]
        if deputy then
          for _, skillName in ipairs(deputy:getSkillNameList()) do
            if not player:hasSkill(skillName, true, true) then
              room:notifySkillInvoked(player, self.name, "defensive")
              room:handleAddLoseSkills(player, skillName)
            end
          end
        end
      end
    end
    if generalToCheck then
      for _, skillName in ipairs(generalToCheck:getSkillNameList()) do
        if not table.find(player.player_skills, function(skill)
              return skill.name == skillName
            end) then
          room:notifySkillInvoked(player, self.name, "defensive")
          room:handleAddLoseSkills(player, skillName)
        end
      end
    end
  end,
})

YC_ShenZhiBiYou:addEffect(fk.BeforePropertyChange, {
  mute = true,
  global = true,
  priority = 203700,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or table.contains(protectedGenerals, target.deputyGeneral) or target:getMark("@@ShenZhiBiYou") > 0
    if isProtectedPlayer then
      if target:getMark("@@ShenZhiBiYou") > 0 then
        if data.general and target.general ~= data.general then
          return true
        end
        if data.deputyGeneral and target.deputyGeneral ~= data.deputyGeneral then
          return true
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room   
    if data.from == target and ((data.general and data.general ~= target.general) or (data.deputyGeneral and data.deputyGeneral ~= target.deputyGeneral)) then
      if data.general and data.general ~= target.general then
        data.general = target.general
      end
      if data.deputyGeneral and data.deputyGeneral ~= target.deputyGeneral then
        data.deputyGeneral = target.deputyGeneral
      end
      return
    end
    if data.general and (table.contains(protectedGenerals, target.general) or target:getMark("@@ShenZhiBiYou") > 0) and not (table.contains(protectedGenerals, data.general) or data.general == target.general) then
      data.general = target.general
    end
    if data.deputyGeneral and (table.contains(protectedGenerals, target.deputyGeneral) or target:getMark("@@ShenZhiBiYou") > 0) and not (table.contains(protectedGenerals, data.deputyGeneral) or data.deputyGeneral == target.deputyGeneral) then
      data.deputyGeneral = target.deputyGeneral
    end
  end,
})

YC_ShenZhiBiYou:addEffect(fk.AfterPropertyChange, {
  mute = true,
  global = true,
  priority = 203800,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local isProtectedPlayer = table.contains(protectedGenerals, player.general) or table.contains(protectedGenerals, player.deputyGeneral) or player:getMark("@@ShenZhiBiYou") > 0
    return isProtectedPlayer and player:getMark("@@ShenZhiBiYou") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@ShenZhiBiYou", 1)
    
  end,
})

YC_ShenZhiBiYou:addEffect(functions.shixinBeforeAcquireDeputy, {
  mute = true,
  global = true,
  priority = 203900,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not target then return false end
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or 
                             table.contains(protectedGenerals, target.deputyGeneral) or 
                             target:getMark("@@ShenZhiBiYou") > 0
    return isProtectedPlayer and target:getMark("@@ShenZhiBiYou") > 0 and 
           data.general and not table.contains(protectedGenerals, data.general)
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    data.general = nil
  end,
})

YC_ShenZhiBiYou:addEffect(functions.shixinBeforeLoseDeputy, {
  mute = true,
  global = true,
  priority = 204000,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not target then return false end
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or 
                             table.contains(protectedGenerals, target.deputyGeneral) or 
                             target:getMark("@@ShenZhiBiYou") > 0
    return isProtectedPlayer and target:getMark("@@ShenZhiBiYou") > 0 and 
           data.general and table.contains(protectedGenerals, data.general)
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    data.general = nil
  end,
})

YC_ShenZhiBiYou:addEffect(functions.MainGeneralBeforeChange, {
  mute = true,
  global = true,
  priority = 204100,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not target then return false end
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or 
                             table.contains(protectedGenerals, target.deputyGeneral) or 
                             target:getMark("@@ShenZhiBiYou") > 0
    return isProtectedPlayer and target:getMark("@@ShenZhiBiYou") > 0 and 
           data.general and not table.contains(protectedGenerals, data.general)
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    data.general = nil
  end,
})

YC_ShenZhiBiYou:addEffect(functions.MainGeneralBeforeAcquire, {
  mute = true,
  global = true,
  priority = 204200,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not target then return false end
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or 
                             table.contains(protectedGenerals, target.deputyGeneral) or 
                             target:getMark("@@ShenZhiBiYou") > 0
    return isProtectedPlayer and target:getMark("@@ShenZhiBiYou") > 0 and 
           data.general and not table.contains(protectedGenerals, data.general)
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    data.general = nil
  end,
})

YC_ShenZhiBiYou:addEffect(functions.MainGeneralBeforeLose, {
  mute = true,
  global = true,
  priority = 204300,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not target then return false end
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or 
                             table.contains(protectedGenerals, target.deputyGeneral) or 
                             target:getMark("@@ShenZhiBiYou") > 0
    return isProtectedPlayer and target:getMark("@@ShenZhiBiYou") > 0 and 
           data.general and table.contains(protectedGenerals, data.general)
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    data.general = nil
  end,
})

YC_ShenZhiBiYou:addEffect(functions.GeneralTransformBefore, {
  mute = true,
  global = true,
  priority = 204400,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not target then return false end
    local isProtectedPlayer = table.contains(protectedGenerals, target.general) or 
                             table.contains(protectedGenerals, target.deputyGeneral) or 
                             target:getMark("@@ShenZhiBiYou") > 0
    if isProtectedPlayer and target:getMark("@@ShenZhiBiYou") > 0 then
      if data.from_general and table.contains(protectedGenerals, data.from_general) and 
         data.to_general and not table.contains(protectedGenerals, data.to_general) then
        return true
      end
      if data.from_general and not table.contains(protectedGenerals, data.from_general) and 
         data.to_general and table.contains(protectedGenerals, data.to_general) then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    data.to_general = data.from_general
  end,
})

YC_ShenZhiBiYou:addEffect(fk.AfterPropertyChange, {
  mute = true,
  global = true,
  priority = 204500,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local isProtectedPlayer = table.contains(protectedGenerals, player.general) or table.contains(protectedGenerals, player.deputyGeneral)
    if isProtectedPlayer then
      local originalGeneral = player:getMark("#@original_general")
      if table.contains(protectedGenerals, player.general) and originalGeneral ~= "" and player.general ~= originalGeneral then
        return true
      end
      local originalDeputy = player:getMark("#@original_deputy")
      if player.deputyGeneral and table.contains(protectedGenerals, player.deputyGeneral) and originalDeputy ~= "" and player.deputyGeneral ~= originalDeputy then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local originalGeneral = player:getMark("#@original_general")
    if table.contains(protectedGenerals, player.general) and originalGeneral ~= "" and player.general ~= originalGeneral then
      room:setPlayerGeneral(player, originalGeneral, true, true)
    end
    local originalDeputy = player:getMark("#@original_deputy")
    if player.deputyGeneral and table.contains(protectedGenerals, player.deputyGeneral) and originalDeputy ~= "" and player.deputyGeneral ~= originalDeputy then
      room:setDeputyGeneral(player, originalDeputy)
    end
  end,
})

YC_ShenZhiBiYou:addEffect(fk.SkillEffect, {
  mute = true,
  global = true,
  priority = 204600,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local infiniteLoopSkills = {"future4","Luashengwei","shenhuatieqi",'Qunyou_keluonuosi_restart',"Luajiupinjinlian","n_digong","n_rengong",
    "kaman_zhu__wuxianjinhua","hx__chouka","control","change_hero","hx__moyin"} 
    if not table.contains(infiniteLoopSkills, data.skill.name) then
      return false
    end
    local room = player.room
    for _, p in ipairs(room:getAllPlayers()) do
      if (p.general == "shen__wuhushangjiang" or p.deputyGeneral == "shen__wuhushangjiang" or
          p.general == "shen__yaoqianshu" or p.deputyGeneral == "shen__yaoqianshu")
          and p:getMark("@@ShenZhiBiYou") > 0 then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getAllPlayers()) do
      if p.dead or p.rest > 0 or p.dying then
        table.insert(targets, p)
      end
    end
    for _, t in ipairs(targets) do
      room:addPlayerMark(t, "@@ultra_protection_ban")
      for _, skill in ipairs(t.player_skills) do
        if skill:isPlayerSkill(t, true) then
          skill.skeleton.max_game_use_time = 0
          skill.times = 0
          if skill.skeleton.max_branches_use_time ~= nil then
            local branch_times = skill.skeleton.max_branches_use_time
              if type(branch_times) == "function" then
                branch_times = branch_times(skill.skeleton, t)
              end
            if branch_times and type(branch_times) == "table" then
              for branch_name, times_table in pairs(branch_times) do
                if times_table and type(times_table) == "table" then
                  for history_type, max_times in pairs(times_table) do
                    times_table[history_type] = 0
                  end
                end
              end
              skill.skeleton.max_branches_use_time = branch_times
            end
          end
        end
      end
    end
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      e:shutdown()
    end
  end,
})

YC_ShenZhiBiYou:addEffect(fk.EnterDying, {
  priority = 205000,
  global = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return (player.general == "shen__wuhushangjiang" or player.deputyGeneral == "shen__wuhushangjiang" or
            player.general == "shen__yaoqianshu" or player.deputyGeneral == "shen__yaoqianshu"
            and player:getMark("@@ShenZhiBiYou") > 0)
            and target.general ~= "shen__wuhushangjiang" and target.deputyGeneral ~= "shen__wuhushangjiang"
            and target.general ~= "shen__yaoqianshu" and target.deputyGeneral ~= "shen__yaoqianshu"
            and target:getMark("@@ShenZhiBiYou") == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    room:killPlayer({ who = target, killer = player})
    target._splayer:setDied(true)
    for _, p in ipairs(room:getAllPlayers()) do
      if p.dead or p.rest > 0 or p.dying then
        table.insert(targets, p)
      end
    end
    table.insertIfNeed(targets, data.who)
    for _, t in ipairs(targets) do
      for _, skill in ipairs(t.player_skills) do
        if skill:isPlayerSkill(t, true) then
          skill.skeleton.max_game_use_time = 0
          skill.times = 0
          if skill.skeleton.max_branches_use_time ~= nil then
            local branch_times = skill.skeleton.max_branches_use_time
              if type(branch_times) == "function" then
                branch_times = branch_times(skill.skeleton, t)
              end
            if branch_times and type(branch_times) == "table" then
              for branch_name, times_table in pairs(branch_times) do
                if times_table and type(times_table) == "table" then
                  for history_type, max_times in pairs(times_table) do
                    times_table[history_type] = 0
                  end
                end
              end
              skill.skeleton.max_branches_use_time = branch_times
            end
          end
        end
      end
    end
  end,
  on_use = Util.FalseFunc
})

YC_ShenZhiBiYou:addEffect(fk.EnterDying, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and (player.dying or player.dead) and
        (player.general == "shen__wuhushangjiang" or player.deputyGeneral == "shen__wuhushangjiang"
          and player:getMark("@@ShenZhiBiYou") > 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
    room.logic:breakTurn()
    room.logic:breakEvent()
  end,
})

YC_ShenZhiBiYou:addEffect(fk.AskForPeachesDone, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.hp <= 0 and player.dying and
        (player.general == "shen__wuhushangjiang" or player.deputyGeneral == "shen__wuhushangjiang"
          and player:getMark("@@ShenZhiBiYou") > 0)
  end,
  on_use = function(self, event, target, player, data)
    data.ignoreDeath = true
    local room = player.room
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
    room.logic:breakTurn()
    room.logic:breakEvent()
  end,
})

YC_ShenZhiBiYou:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and (player.dying or player.dead) and
        (player.general == "shen__wuhushangjiang" or player.deputyGeneral == "shen__wuhushangjiang"
          and player:getMark("@@ShenZhiBiYou") > 0)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "hp", 9)
    room:setPlayerProperty(player, "maxHp", 9)
    room.logic:breakTurn()
    room.logic:breakEvent()
  end,
})

YC_ShenZhiBiYou:addEffect(fk.GameStart, {
  global = true,
  priority = 270000,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player._splayer:getScreenName() == "YiChenSama"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#YC_ShenZhiBiYou-YiChenSama"}) then
      room:handleAddLoseSkills(player, "YC_City_Hunter", nil, false, false)
    end
  end
})

YC_ShenZhiBiYou:addEffect(fk.GameStart, {
  global = true,
  priority = 888888,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player._splayer:getScreenName() == "YiChenSama" or player._splayer:getScreenName() == "是共赏ya"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
      room:setPlayerMark(player, "YC_Hongli", 1)
  end
})

Fk:loadTranslationTable{
  ["YC_ShenZhiBiYou"] = "神之庇佑",
  ["@@ShenZhiBiYou"] = "神之庇佑",
  ["YC_Hongli"] = "逸晨的红利",
  [":YC_ShenZhiBiYou"] = "永恒技，无论在哪个世界，无论是否在场，受到庇佑之人不会失去技能和更换武将牌。",
  ["#YC_ShenZhiBiYou-YiChenSama"] = "是否启用 City Hunter ",
}

return YC_ShenZhiBiYou
