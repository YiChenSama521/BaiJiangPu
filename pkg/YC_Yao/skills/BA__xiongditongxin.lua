local ba__xiongditongxin = fk.CreateSkill {
    name = "ba__xiongditongxin",
    tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
    ["ba__xiongditongxin"] = "兄弟同心",
    [":ba__xiongditongxin"] = "锁定技，若你的体力值：大于已损失体力值，你拥有技能【智囊】；小于已损失体力值，你拥有技能【蛮力】。",
}

local function updateSkills(player)
    local room = player.room
    local hp = player.hp
    local lost = player.maxHp - hp
    if hp > lost then
        if not player:hasSkill("ba__zhinang", true) then
            room:handleAddLoseSkills(player, "ba__zhinang", nil, true, false)
        end
        if player:hasSkill("ba__manli", true) then
            room:handleAddLoseSkills(player, "-ba__manli", nil, true, false)
        end
    elseif hp < lost then
        if not player:hasSkill("ba__manli", true) then
            room:handleAddLoseSkills(player, "ba__manli", nil, true, false)
        end
        if player:hasSkill("ba__zhinang", true) then
            room:handleAddLoseSkills(player, "-ba__zhinang", nil, true, false)
        end
    end
end

ba__xiongditongxin:addAcquireEffect(function(self, player, is_start)updateSkills(player)end)

ba__xiongditongxin:addEffect(fk.HpChanged, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(self)
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        updateSkills(player)
    end,
})

ba__xiongditongxin:addEffect(fk.MaxHpChanged, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(self)
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        updateSkills(player)
    end,
})

ba__xiongditongxin:addEffect(fk.EventAcquireSkill, {
    can_trigger = function(self, event, target, player, data)
        return target == player and data.skill == self
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        updateSkills(player)
    end,
})

ba__xiongditongxin:addLoseEffect(function(self, player)
    local room = player.room
    if player:hasSkill("ba__zhinang", true) then
        room:handleAddLoseSkills(player, "-ba__zhinang", nil, true, false)
    end
    if player:hasSkill("ba__manli", true) then
        room:handleAddLoseSkills(player, "-ba__manli", nil, true, false)
    end
end)

return ba__xiongditongxin
