local qc__shengqu = fk.CreateSkill({
    name = "qc__shengqu",
    tags = { Skill.Permanent, Skill.Compulsory },
})
Fk:loadTranslationTable{
    ["qc__shengqu"] = "圣躯",
    [":qc__shengqu"] = "永恒技，在你受到<a href='#qc__shengqu'>负面效果</a>前，你可将此负面效果改为你指定的另一种<a href='#qc__shengqu'>负面效果</a>。",
    ["#qc__shengqu"] = "（负面效果：受到伤害，失去体力，减体力上限，弃置牌，失去技能，技能失效，横置，翻面）",
    ["@[qc__shengqu]"] = "圣躯",
    ["qc__shengqu1"] = "受到伤害",
    ["qc__shengqu2"] = "失去体力",
    ["qc__shengqu3"] = "减体力上限",
    ["qc__shengqu4"] = "弃置牌",
    ["qc__shengqu5"] = "失去技能",
    ["qc__shengqu6"] = "技能失效",
    ["qc__shengqu7"] = "横置",
    ["qc__shengqu8"] = "翻面",

    ["#qc__shengqu1-invoke"] = "你即将%arg，是否发动【圣躯】改为其他负面效果？",
    ["#qc__shengqu2-invoke"] = "你即将%arg，是否发动【圣躯】改为其他负面效果？（本回合已发动 %arg2 次）",
    ["#qc__shengquLog"] = "%from 发动了【圣躯】，将 %arg 改为了 %arg2",
    ["#cancelDismantle"] = "受【%arg】影响，取消了此次弃牌",
}
local YC = require "packages.BaiJiangPu.functions"

--
---@param player ServerPlayer
local GetShengquChoice = function(player, current_index)
  local choices = {}
  for i = 1, 8 do
    if i ~= current_index then
      if not (i == 4 and player:isNude()) then
        table.insert(choices, "qc__shengqu" .. i)
      end
    end
  end

  local choice = player.room:askToChoice(player, {
    choices = choices,
    skill_name = qc__shengqu.name,
  })
  return tonumber(choice:sub(12))
end
--永恒技实现，放置在最上方
qc__shengqu:addLoseEffect(function(self, player, is_death)
    local room = player.room
    room:handleAddLoseSkills(player, qc__shengqu.name, nil, false, true)
end)

Fk:addQmlMark {
  name = "qc__shengqu",
  how_to_show = function(name, value)
    if type(value) == "table" then
      return tostring(#value)
    end
    return " "
  end,
  qml_path = "packages/BaiJiangPu/qml/DetailBox"
}

local ShengquMapper = {
  [fk.DamageInflicted] = 1,
  [fk.PreHpLost] = 2,
  [fk.BeforeMaxHpChanged] = 3,
  [fk.BeforeCardsMove] = 4,
  [fk.EventLoseSkill] = 5,
  [fk.AfterSkillEffect] = 6,
  [fk.BeforeChainStateChange] = 7,
  [fk.BeforeTurnOver] = 8,
}

qc__shengqu:addEffect(fk.DamageInflicted, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name) and target == player then
      return target == player and (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu1"))
        end
    end,
    on_cost = function(self, event, target, player, data)
        if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu1") then
            return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
            prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu1" .. ":" .. player:getMark("qc__shengqu-turn") })
        else
            return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
            prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu1" })
        end
    end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu1") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      local rand = GetShengquChoice(player, 1)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu1",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
      data:preventDamage()
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu1")
      room:addPlayerMark(player, "qc__shengqu_record1", data.damage)
      data:preventDamage()
    end
  end,
})
qc__shengqu:addEffect(fk.PreHpLost, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) then
      if player:hasSkill(qc__shengqu.name) then
        if target == player then
          return target == player and
              (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu2"))
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu2") then
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu2" .. ":" .. player:getMark("qc__shengqu-turn") })
    else
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu2" })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu2") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      local rand = GetShengquChoice(player, 2)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu2",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
      data:preventHpLost()
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu2")
      room:addPlayerMark(player, "qc__shengqu_record2", data.num)
      data:preventHpLost()
    end
  end,
})
qc__shengqu:addEffect(fk.BeforeMaxHpChanged, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) then
      if player:hasSkill(qc__shengqu.name) then
        if target == player then
          if data.num > 0 then return end
          return target == player and
              (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu3"))
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu3") then
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu3" .. ":" .. player:getMark("qc__shengqu-turn") })
    else
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu3" })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu3") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      local rand = GetShengquChoice(player, 3)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu3",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
      data:preventMaxHpChange()
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu3")
      room:addPlayerMark(player, "qc__shengqu_record3", -data.num)
      data:preventMaxHpChange()
    end
  end,
})
qc__shengqu:addEffect(fk.BeforeCardsMove, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) then
      if player:hasSkill(qc__shengqu.name) then
        for _, move in ipairs(data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            if (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu4")) then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  return true
                end
              end
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if #player:getTableMark("@[qc__shengqu]") > 0 and
        table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu4") then
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu4" .. ":" .. player:getMark("qc__shengqu-turn") })
    else
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu4" })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu4") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      local ids = {}
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          local new_info = {}
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              table.insertIfNeed(ids, info.cardId)
            else
              table.insert(new_info, info)
            end
            if #ids > 0 then
              move.moveInfo = new_info
            end
          end
        end
      end
      room:sendLog {
        type = "#cancelDismantle",
        card = ids,
        arg = qc__shengqu.name,
      }
      local rand = GetShengquChoice(player, 4)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu4",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu4")
      if event == fk.BeforeCardsMove then
        local ids = {}
        for _, move in ipairs(data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            local new_info = {}
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                table.insertIfNeed(ids, info.cardId)
              else
                table.insert(new_info, info)
              end
              if #ids > 0 then
                move.moveInfo = new_info
              end
            end
          end
        end
        room:addPlayerMark(player, "qc__shengqu_record4", #ids)
        room:sendLog {
          type = "#cancelDismantle",
          card = ids,
          arg = qc__shengqu.name,
        }
      end
    end
  end,
})
qc__shengqu:addEffect(fk.EventLoseSkill, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) then
      if player:hasSkill(qc__shengqu.name) then
        if target == player then
          if not (data.skill:isPlayerSkill(player) and data.skill.visible) then return end
          return target == player and
              (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu5"))
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu5") then
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu5" .. ":" .. player:getMark("qc__shengqu-turn") })
    else
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu5" })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu5") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      room:handleAddLoseSkills(player, data.skill.name, nil, false, false)
      local rand = GetShengquChoice(player, 5)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu5",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu5")
      room:handleAddLoseSkills(player, data.skill.name, nil, false, false)
    end
  end,
})
qc__shengqu:addEffect(fk.AfterSkillEffect, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) and table.find(player:getMarkNames(), function(name)
          return name:startsWith(MarkEnum.UncompulsoryInvalidity) or name:startsWith(MarkEnum.InvalidSkills)
        end) then
      return (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu6") and player:getMark("qc__shengqu6_n-turn") == 0) or
          (table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu6") and player:getMark("qc__shengqu6_y-turn") == 0)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu6") then
      if player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu6" .. ":" .. player:getMark("qc__shengqu-turn") }) == false then
        player.room:addPlayerMark(player, "qc__shengqu6_y-turn")
        return false
      end
      return true
    else
      if player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
      prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu6" }) == false then
        player.room:addPlayerMark(player, "qc__shengqu6_n-turn")
        return false
      end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu6") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      for _, name in ipairs(player:getMarkNames()) do
        if name:startsWith(MarkEnum.UncompulsoryInvalidity) or name:startsWith(MarkEnum.InvalidSkills) then
          room:setPlayerMark(player, name, 0)
        end
      end
      local rand = GetShengquChoice(player, 6)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu6",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu6")
      for _, name in ipairs(player:getMarkNames()) do
        if name:startsWith(MarkEnum.UncompulsoryInvalidity) or name:startsWith(MarkEnum.InvalidSkills) then
          room:setPlayerMark(player, name, 0)
        end
      end
    end
  end,
})
qc__shengqu:addEffect(fk.BeforeChainStateChange, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) then
      if player:hasSkill(qc__shengqu.name) then
        if player.chained then return end
        return target == player and
            (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu7"))
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu7") then
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
        prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu7" .. ":" .. player:getMark("qc__shengqu-turn") })
    else
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
        prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu7" })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu7") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      local rand = GetShengquChoice(player, 7)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu7",
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
      data.prevented = true
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu7")
      data.prevented = true
    end
  end,
})
qc__shengqu:addEffect(fk.BeforeTurnOver, {
  name = "qc__shengqu",
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qc__shengqu.name,true) then
      if player:hasSkill(qc__shengqu.name) then
        if target == player then
          if not player.faceup then return end
          return target == player and
              (not table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu8"))
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu8") then
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
        prompt = "#qc__shengqu2-invoke:::" .. "qc__shengqu8" .. ":" .. player:getMark("qc__shengqu-turn") })
    else
      return player.room:askToSkillInvoke(player, { skill_name = qc__shengqu.name,
        prompt = "#qc__shengqu1-invoke:::" .. "qc__shengqu8" })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark("@[qc__shengqu]"), "qc__shengqu8") then
      room:addPlayerMark(player, "qc__shengqu-turn", 1)
      local rand = GetShengquChoice(player, 8)
      room:sendLog {
        type = "#qc__shengquLog",
        from = player.id,
        arg = "qc__shengqu" .. 8,
        arg2 = "qc__shengqu" .. rand,
        toast = true,
      }
      local count = 1
      if rand < 5 then
        count = player:getMark("qc__shengqu_record" .. rand) == 0 and 1 or player:getMark("qc__shengqu_record" .. rand)
      end
      YC.DoDeBuff(player, rand, count, qc__shengqu.name)
      data.prevented = true
    else
      room:addTableMark(player, "@[qc__shengqu]", "qc__shengqu" .. 8)
      data.prevented = true
    end
  end,
})





return qc__shengqu
