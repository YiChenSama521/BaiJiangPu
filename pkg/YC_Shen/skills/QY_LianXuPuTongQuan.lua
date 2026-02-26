local lianxuputongquan = fk.CreateSkill({
  name = "lianxuputongquan", --技能内部名称，要求唯一性
  tags = {Skill.Compulsory}, -- 技能标签，Skill.Compulsory代表锁定技，支持存放多个标签
})

Fk:loadTranslationTable{
  ["lianxuputongquan"] = "连续普通拳",
  [":lianxuputongquan"] = "锁定技，你使用牌无次数限制，当你使用伤害牌指定其他角色时，可选择任意数量个目标（包含自己）。",
  ["#lianxuputongquan-tos"] = "连续普通拳：为此 %arg 选择任意个额外的目标",
}
-- 你使用牌无次数限制
lianxuputongquan:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return player:hasSkill(self.name) and card
  end,
})

-- 当你使用伤害牌指定其他角色时，可增加任意数量个目标（包含自己）
lianxuputongquan:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianxuputongquan.name) and data.card and data.card.is_damage_card and table.find(data.tos, function (p) return p ~= player end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getAlivePlayers(), function (p)
      return not table.contains(data.tos, p)
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = #targets,
      prompt = "#lianxuputongquan-tos:::" .. data.card:toLogString(),
      skill_name = self.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { to = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).to
    room:doIndicate(player, targets)
    data:addTarget(targets)
  end,
})

return lianxuputongquan
