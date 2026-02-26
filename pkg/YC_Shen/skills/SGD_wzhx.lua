local sgd_wzhx = fk.CreateSkill({
    name = "sgd_wzhx",
    tags = {Skill.Permanent},
})

Fk:loadTranslationTable{
    ["sgd_wzhx"] = "威震华夏",
    [":sgd_wzhx"] = "永恒技，你的回合内，其他受到你造成伤害的角色获得”威震“标记持续至本轮结束，拥有”威震“标记的角色发动技能时取消发动。",
    ["@@sgd_wzhx-round"] = "威震",
    ["$sgd_wzhx1"] = "还不速速领死！",
    ["$sgd_wzhx2"] = "汝等鼠辈，岂敢与某相抗！",
    ["$sgd_wzhx3"] = "义襄千里，威震华夏！",
}
sgd_wzhx:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_wzhx.name, nil, false, true)
end)

-- 主要效果：造成伤害后施加标记
sgd_wzhx:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(sgd_wzhx.name) and data.to ~= player and target:isAlive() and player:getMark("@@sgd_wzhx-round") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(data.to, "@@sgd_wzhx-round", 1)
  end,
})

-- 触发发动
sgd_wzhx:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and player:hasSkill(sgd_wzhx.name) and target:getMark("@@sgd_wzhx-round") == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      e:shutdown()
    end
  end,
})

return sgd_wzhx