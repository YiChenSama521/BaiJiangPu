local YC_YQS_rule = fk.CreateSkill {
  name = "#YC_YQS_rule&",
}

Fk:loadTranslationTable {
  ["#YC_YQS_rule&"] = "摇钱树规则",
  ["@YC_YQS_ticket"] = "摇钱树挑战券",
  ["@YC_YQS_damage"] = "造成伤害",
  ["@YC_YQS_damaged"] = "受到伤害",
  ["@YC_YQS_gold"] = "基础获得",
}

local YC_functions = require "packages.BaiJiangPu.functions"

YC_YQS_rule:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return target == player and target.id < 0 and player.room:getSettings("YQS_Difficulty")
  end,
  on_refresh = function(self, event, target, player, data)
    local diff = player.room:getSettings("YQS_Difficulty") or 1
    if diff > 1 then
      data.damage = data.damage * diff
    end
  end
})

-- 记录玩家造成的伤害
YC_YQS_rule:addEffect(fk.Damage, {
  can_refresh = function(self, event, target, player, data)
    return target == player and target.id > 0 and data.to.id < 0
  end,
  on_refresh = function(self, event, target, player, data)
    local num = math.min(player:getMark("@YC_YQS_damage") + data.damage, 88)
    player.room:setPlayerMark(target, "@YC_YQS_damage", num)

    local damage, damaged = player:getMark("@YC_YQS_damage"), player:getMark("@YC_YQS_damaged")
    local diff = player.room:getSettings("YQS_Difficulty") or 1
    local num = damage * 100 - damaged * 50
    player.room:setPlayerMark(player, "@YC_YQS_gold", num * diff)
  end
})

-- 记录玩家受到的伤害
YC_YQS_rule:addEffect(fk.DamageInflicted, {
  priority = 0.000001,
  can_refresh = function(self, event, target, player, data)
    return target == player and target.id > 0 and data.from and data.from.id < 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@YC_YQS_damaged", data.damage)

    local damage, damaged = player:getMark("@YC_YQS_damage"), player:getMark("@YC_YQS_damaged")
    local diff = player.room:getSettings("YQS_Difficulty") or 1
    local num = damage * 100 - damaged * 50
    player.room:setPlayerMark(player, "@YC_YQS_gold", num * diff)
  end
})

YC_YQS_rule:addEffect(fk.GameFinished, {
  priority = 0.1,
  can_refresh = function(self, event, target, player, data)
    return player.role == "lord" and player.room:getBanner("YC_YQS_rule_finished")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local num = room:getBanner("YC_YQS_rule_finished") or 0
    room:setBanner("YC_YQS_rule_finished", nil)
    local humanPlayers = table.filter(room.players, function(p) return p.id > 0 end)
    if #humanPlayers <= 0 then return end
    local lord = humanPlayers[1]

    if num > 0 then
      local diff = room:getSettings("YQS_Difficulty") or 1
      local items = lord:getGlobalSaveState("coins_System_items") or {}
      local ticket = items["YC_YQS_ticket"] or num
      items["YC_YQS_ticket"] = ticket - diff
      lord:saveGlobalState("coins_System_items", items)
    end

    local damage, damaged = lord:getMark("@YC_YQS_damage"), lord:getMark("@YC_YQS_damaged")
    local gold = damage * 100 - damaged * 50
    if gold == 0 then return end
    local diff = room:getSettings("YQS_Difficulty") or 1
    gold = gold * diff

    --防止屯屯鼠？maybe
    -- local total_gold = YC_functions.ChangePlayerMoney(lord, 0)
    -- if diff == 10 and total_gold >= 1000000 then
    --   YC_functions.ChangePlayerMoney(lord, -100000)
    -- end

    local win = data:split("+")
    if table.contains(win, lord.role) then
      YC_functions.ChangePlayerMoney(lord, math.floor(gold * 2))
    else
      YC_functions.ChangePlayerMoney(lord, math.floor(gold * 0.75))
    end
  end
})

return YC_YQS_rule
