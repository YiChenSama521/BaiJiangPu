local functions = {}

--- 改变玩家金币
--- @param player ServerPlayer @ 玩家
--- @param num integer @ 变更值
--- @return integer @ 返回当前金币
function functions.ChangePlayerMoney(player, num)
  if player.id < 0 then return 0 end
  num = num or 0
  local globalData = player:getGlobalSaveState("CS_System_Data") or {}
  if next(globalData) == nil then
    local data = player:getGlobalSaveState("DR_System_Data") or {}
    globalData.gold = data.gold and data.gold or 0
  end
  globalData.gold = globalData.gold + num
  if num ~= 0 then
    player:saveGlobalState("CS_System_Data", globalData)
    player.room:sendLog {
      type = "#YC_YQS_Change_Log",
      arg = player._splayer:getScreenName(),
      arg2 = num > 0 and "获得" or "消耗",
      arg3 = math.abs(num),
      toast = true,
    }
  end
  return globalData.gold
end

--- 送花给除自己外所有人
---@param player ServerPlayer
function functions.songhua(player)
  local room = player.room
  local targets = {}
  for _, p in ipairs(room.alive_players) do
    if p ~= player then
      table.insert(targets, p)
      player:chat(("$@Wine:%d"):format(p.id))
    end
  end
  if #targets > 0 then
    room:doIndicate(player, targets)
  end
end

--- 除自己外所有人砸蛋给自己
---@param player ServerPlayer
function functions.zadan(player)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    if p ~= player then
      room:doIndicate(p, { player })
      p:chat(("$@Shoe:%d"):format(player.id))
    end
  end
end



functions.shixinData = TriggerData:subclass("evol_shixinData")
functions.shixinTriggerEvent = TriggerEvent:subclass("evol_shixinEvent")

functions.shixinBeforeAcquireDeputy = functions.shixinTriggerEvent:subclass("fk.evol_shixinBeforeAcquireDeputy")

functions.shixinBeforeLoseDeputy = functions.shixinTriggerEvent:subclass("fk.evol_shixinBeforeLoseDeputy")

functions.shixinAcquireDeputy = functions.shixinTriggerEvent:subclass("fk.evol_shixinAcquireDeputy")

functions.shixinLoseDeputy = functions.shixinTriggerEvent:subclass("fk.evol_shixinLoseDeputy")
functions.MainGeneralData = TriggerData:subclass("evol_MainGeneralData")
functions.MainGeneralTriggerEvent = TriggerEvent:subclass("evol_MainGeneralEvent")

functions.MainGeneralBeforeAcquire = functions.MainGeneralTriggerEvent:subclass("fk.evol_MainGeneralBeforeAcquire")

functions.MainGeneralBeforeLose = functions.MainGeneralTriggerEvent:subclass("fk.evol_MainGeneralBeforeLose")

functions.MainGeneralAcquire = functions.MainGeneralTriggerEvent:subclass("fk.evol_MainGeneralAcquire")

functions.MainGeneralLose = functions.MainGeneralTriggerEvent:subclass("fk.evol_MainGeneralLose")

functions.MainGeneralBeforeChange = functions.MainGeneralTriggerEvent:subclass("fk.evol_MainGeneralBeforeChange")

functions.MainGeneralAfterChange = functions.MainGeneralTriggerEvent:subclass("fk.evol_MainGeneralAfterChange")
functions.GeneralTransformData = TriggerData:subclass("evol_GeneralTransformData")
functions.GeneralTransformTriggerEvent = TriggerEvent:subclass("evol_GeneralTransformEvent")

functions.GeneralTransformBefore = functions.GeneralTransformTriggerEvent:subclass("fk.evol_GeneralTransformBefore")

functions.GeneralTransformAfter = functions.GeneralTransformTriggerEvent:subclass("fk.evol_GeneralTransformAfter")

functions.GeneralTransformCancel = functions.GeneralTransformTriggerEvent:subclass("fk.evol_GeneralTransformCancel")

function functions.findRandomSkillByChar(char, player, room, x, y, skill_name)
  local available_skills = {}
  for general_name, general in pairs(Fk.generals) do
    local is_hegemony_general = general_name:find("ty_heg__") or 
                                general_name:find("os_heg__") or 
                                general_name:find("zq_heg__") or 
                                general_name:find("jy_heg__") or 
                                general_name:find("hs__") or
                                general_name:find("heg__")
    if not is_hegemony_general then
      for _, skill_id in ipairs(general:getSkillNameList()) do
        local skill = Fk.skills[skill_id]
        if skill and 
           not skill_id:startsWith("#") and     
           not skill_id:find("heg__") and     
           not skill.attached_equip and           
           not player:hasSkill(skill_id) then  
          local desc = Fk:translate(":" .. skill_id)
          if desc then
            if (char:match("%a") and desc:lower():find(char:lower())) or
               (char:match("%d") and desc:find(char)) then
              table.insert(available_skills, {name = skill_id, desc = desc})
            end
          end
        end
      end
    end
  end
  local unique_skills = {}
  for _, skill in ipairs(available_skills) do
    unique_skills[skill.name] = skill
  end
  available_skills = {}
  for skill_name, skill in pairs(unique_skills) do
    table.insert(available_skills, skill)
  end
  x = math.min(x, #available_skills)
  if x > 0 then
    local candidates = {}
    local shuffled = {}
    for _, skill in ipairs(available_skills) do
      table.insert(shuffled, skill)
    end
    table.shuffle(shuffled)
    for i = 1, x do
      table.insert(candidates, shuffled[i])
    end
    local choices = {}
    local choice_map = {}
    for i, skill in ipairs(candidates) do
      local choice_text = skill.name
      table.insert(choices, choice_text)
      choice_map[choice_text] = skill.name
    end
    local selected_skills = {}
    for i = 1, y do
      if #choices == 0 then break end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = skill_name,
        prompt = "请选择要获得的技能",
        detailed = true
      })
      local selected_skill = choice_map[choice]
      table.insert(selected_skills, selected_skill)
      for j = #choices, 1, -1 do
        if choice_map[choices[j]] == selected_skill then
          table.remove(choices, j)
          break
        end
      end
    end
    return selected_skills
  end
  return {}
end

function functions.reforgeSkill(player, room, skill_name, prompt_remove, prompt_gain, num_choices)
  num_choices = num_choices or 3
  local skills = {}
  for _, skill in ipairs(player.player_skills) do
    if not skill.attached_equip and not skill.name:startsWith("#") then
      table.insert(skills, skill.name)
    end
  end
  if #skills == 0 then return false end
  local to_remove = room:askToChoice(player, {
    choices = skills,
    skill_name = skill_name,
    prompt = prompt_remove,
    detailed = true
  })
  if not to_remove then return false end
  room:handleAddLoseSkills(player, "-"..to_remove, nil)
  local all_skills = {}
  for _, general in ipairs(Fk:getAllGenerals()) do
    for _, skill_id in ipairs(general:getSkillNameList()) do
      local skill = Fk.skills[skill_id]
      if skill and not player:hasSkill(skill_id) and 
         not skill_id:startsWith("#") and
         not skill.attached_equip then
        table.insertIfNeed(all_skills, skill_id)
      end
    end
  end
  if #all_skills == 0 then return true end
  local choices = table.random(all_skills, math.min(num_choices, #all_skills))
  local new_skill = room:askToChoice(player, {
    choices = choices,
    skill_name = skill_name,
    prompt = prompt_gain,
    optional = true,
    detailed = true
  })
  if new_skill then
    room:handleAddLoseSkills(player, new_skill, nil)
  end
  return true
end

function functions.isEnemy(from, to)
  if from.id == to.id then return false end 
  if from.role == "lord" or from.role == "loyalist" then
    return (to.role ~= "lord" and to.role ~= "loyalist")
  elseif from.role == "rebel" then
    return (to.role == "lord" or to.role == "loyalist")
  elseif from.role == "renegade" then
    return true 
  end
  return false 
end

function functions.isFriend(from, to)
  return not functions.isEnemy(from, to)
end

function functions.removeAllSkills(player, room, tag_name, mark_name)
  tag_name = tag_name or "removed_skills"
  local skills = {}
  for _, skill in ipairs(player.player_skills) do
    if skill.visible and 
       not skill.name:startsWith("#") and 
       not skill.name:endsWith("&") and 
       not skill.cardSkill and 
       not skill:isEquipmentSkill(player) then
      table.insertIfNeed(skills, skill.name)
    end
  end
  player.tag[tag_name] = skills
  for _, skill_name in ipairs(skills) do
    room:handleAddLoseSkills(player, "-" .. skill_name, nil, false, true)
  end
  if mark_name then
    room:setPlayerMark(player, mark_name, 1)
  end
  return skills
end

function functions.restoreRemovedSkills(player, room, tag_name, mark_name)
  tag_name = tag_name or "removed_skills"
  local skills = player.tag[tag_name] or {}
  for _, skill_name in ipairs(skills) do
    room:handleAddLoseSkills(player, skill_name, nil, false, true)
  end
  player.tag[tag_name] = nil
  if mark_name then
    room:setPlayerMark(player, mark_name, 0)
  end
  return skills
end

function functions.transformGeneral(player, room, from_general, to_general, log_type, skills)
  local transformed = false
  if (from_general == nil or player.general == from_general) and not transformed then
    player.general = to_general
    room:broadcastProperty(player, "general")
    transformed = true
  elseif (from_general == nil or player.deputyGeneral == from_general) and not transformed then
    player.deputyGeneral = to_general
    room:broadcastProperty(player, "deputyGeneral")
    transformed = true
  end
  if transformed and log_type then
    room:sendLog{
      type = log_type,
      from = player.id,
    }
  end
  if transformed and skills then
    room:handleAddLoseSkills(player, skills, nil)
  end
  return transformed
end

function functions.transformEquip(install, player, room, general_name, tag_name, transform_log, restore_log, skills)
  if install then
    player.tag[tag_name] = player.general
    local transformed = functions.transformGeneral(player, room, nil, general_name, transform_log, skills)
    return transformed
  else
    local original_general = player.tag[tag_name]
    if original_general then
      local transformed = functions.transformGeneral(player, room, general_name, original_general, restore_log, nil)
      player.tag[tag_name] = nil
      if skills and skills ~= "" then
        room:handleAddLoseSkills(player, "-"..skills, nil, true, false)
      end
      return transformed
    end
    return false
  end
end

function functions.getRandomSkillsFromPackages(player, packages, num, filter_func)
  local room = player.room
  num = num or 2
  if type(packages) == "string" then
    packages = {packages}
  end
  local skill_packages = {}
  for _, pkg_name in ipairs(packages) do
    if Fk.packages[pkg_name] then
      table.insert(skill_packages, Fk.packages[pkg_name])
    end
  end
  if #skill_packages == 0 then
    return nil
  end
  local available_skills = {}
  for _, pkg in ipairs(skill_packages) do
    for _, general in pairs(pkg.generals) do
      for _, skill_id in ipairs(general:getSkillNameList()) do
        local skill = Fk.skills[skill_id]
        if skill and not string.find(skill_id, "^#") and     
           not skill:isEquipmentSkill(player) and               
           not skill.cardSkill and                              
           not player:hasSkill(skill_id) then                 
          if not filter_func or filter_func(skill_id, skill) then
            table.insert(available_skills, skill_id)
          end
        end
      end
    end
  end
  local unique_skills = {}
  for _, skill_id in ipairs(available_skills) do
    unique_skills[skill_id] = true
  end
  available_skills = {}
  for skill_id, _ in pairs(unique_skills) do
    table.insert(available_skills, skill_id)
  end
  if #available_skills < num then
    return nil
  end
  return table.random(available_skills, num)
end

functions.changeMainGeneral = function(player, new_general, reason)
  local room = player.room
  local old_general = player.general
  local data = { general = new_general }
  room.logic:trigger(functions.MainGeneralBeforeChange, player, data)
  player.general = new_general
  room:broadcastProperty(player, "general")
  room.logic:trigger(functions.MainGeneralAfterChange, player, { 
    general = new_general,
    old_general = old_general
  })
  room:sendLog{
    type = "#MainGeneralChanged",
    from = player.id,
    arg = new_general,
    arg2 = old_general,
    toast = true,
  }
end

function functions.evol_advance_enter_hidden(player, reason)
  local room = player.room
  room:setPlayerMark(player, "__evol_advance_hidden", 1)
  if reason then
    room:setPlayerMark(player, "__evol_advance_hidden_reason", reason)
  end
  room:setPlayerProperty(player, "visible", false)
  room:sendLog{
    type = "#EvolAdvanceHidden",
    from = player.id,
    arg = reason or "jin",
    toast = true,
  }
  return true
end

function functions.evol_advance_exit_hidden(player)
  local room = player.room
  if player:getMark("__evol_advance_hidden") == 0 then
    return false
  end
  room:removePlayerMark(player, "__evol_advance_hidden")
  room:removePlayerMark(player, "__evol_advance_hidden_reason")
  room:setPlayerProperty(player, "visible", true)
  room:sendLog{
    type = "#EvolAdvanceVisible",
    from = player.id,
    toast = true,
  }
  return true
end

function functions.evol_advance_is_hidden(player)
  return player:getMark("__evol_advance_hidden") > 0
end

function functions.evol_advance_get_hidden_reason(player)
  return player:getMark("__evol_advance_hidden_reason") or ""
end

functions.acquireMainGeneral = function(player, general)
  local room = player.room
  local data = { general = general }
  room.logic:trigger(functions.MainGeneralBeforeAcquire, player, data)
  if data.general then
    room.logic:trigger(functions.MainGeneralAcquire, player, { general = data.general })
    room:sendLog{
      type = "#MainGeneralAcquired",
      from = player.id,
      arg = data.general,
      toast = true,
    }
  end
end

functions.loseMainGeneral = function(player, general)
  local room = player.room
  local data = { general = general }
  room.logic:trigger(functions.MainGeneralBeforeLose, player, data)
  if data.general then
    room.logic:trigger(functions.MainGeneralLose, player, { general = data.general })
    room:sendLog{
      type = "#MainGeneralLost",
      from = player.id,
      arg = data.general,
      toast = true,
    }
  end
end

functions.triggerGeneralTransform = function(player, from_general, to_general, reason)
  local room = player.room
  local data = {
    from_general = from_general,
    to_general = to_general,
    reason = reason
  }
  room.logic:trigger(functions.GeneralTransformBefore, player, data)
  if not data.cancelled then
    room.logic:trigger(functions.GeneralTransformAfter, player, data)
    room:sendLog{
      type = "#GeneralTransformed",
      from = player.id,
      arg = to_general,
      arg2 = from_general,
      toast = true,
    }
  else
    room.logic:trigger(functions.GeneralTransformCancel, player, data)
  end
end

Fk:loadTranslationTable{
  ["#MainGeneralChanged"] = "%from 的从 %arg2 变更为 %arg",
  ["#MainGeneralAcquired"] = "%from 获得了 %arg",
  ["#MainGeneralLost"] = "%from 失去了 %arg",
  ["#GeneralTransformed"] = "%from 的武将从 %arg2 变身为 %arg",
  ["#shixinLoseDeputy"] = "%from 失去了 %arg",
  ["#shixinAcquireDeputy"] = "%from 获得了 %arg",
}

---获取武将
---@return string[]
function functions.getGenerals()
  local all_generals = {}
  for name, general in pairs(Fk.generals) do
    if not general.total_hidden then
      table.insert(all_generals, name)
    end
  end
  return all_generals
end

---获取技能
---@return string[]
function functions.getSkills()
  local all_skills = {}
  for _, general in pairs(Fk.generals) do
    if not general.hidden and not general.total_hidden then
      for _, skillName in ipairs(general:getSkillNameList()) do
        local s = Fk.skills[skillName]
        if not skillName:startsWith("#") and not skillName:endsWith("&") and not s:isEquipmentSkill()
            and not s.cardSkill and s:isPlayerSkill() then
          table.insertIfNeed(all_skills, skillName)
        end
      end
    end
  end
  return all_skills
end

---释放负面效果
---@param player ServerPlayer --玩家
---@param index integer -- 1:伤害 2:失去体力 3:失去体力上限 4:弃牌 5:失去随机技能 6:技能失效 7:横置 8:翻面
---@param count integer
---@param skill_name string
function functions.DoDeBuff(player, index, count, skill_name)
  local room = player.room
  if index == 1 then
    room:damage {
      to = player,
      damage = count,
      skillName = skill_name,
    }
  elseif index == 2 then
    room:loseHp(player, count, skill_name)
  elseif index == 3 then
    room:changeMaxHp(player, -count)
  elseif index == 4 then
    room:askToDiscard(player, ({skill_name, count, count, true, false}))
  elseif index == 5 then
    local skills = table.map(table.filter(player.player_skills, function(s)
      return s:isPlayerSkill(player) and s.visible
    end), function(s)
      return s.name
    end)
    if #skills > 0 then
      room:handleAddLoseSkills(player, "-" .. table.random(skills), nil, true, false)
    end
  elseif index == 6 then
    for index, value in ipairs(player:getSkillNameList()) do
      room:invalidateSkill(player, value, "-turn")
    end
  elseif index == 7 then
    player:setChainState(true)
  elseif index == 8 then
    player:turnOver()
  end
end



return functions
