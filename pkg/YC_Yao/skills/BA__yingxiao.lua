local ba__yingxiao = fk.CreateSkill {
    name = "ba__yingxiao",
    tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
    ["ba__yingxiao"] = "鹰啸",
    [":ba__yingxiao"] = "锁定技，你的【杀】无法被响应，且对体力值小于等于你的角色造成的伤害增加50%；当你成为敌方角色使用牌的目标后，你令使用者选择是否弃置2张牌，若其未弃置则此牌对你无效。",
    ["#yingxiao_discard"] = "弃置2张牌",
}
--【杀】无法被响应
ba__yingxiao:addEffect(fk.CardUsing, {
    mute = true,
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(ba__yingxiao.name) and data.card and data.card.trueName == "slash"
    end,
    on_use = function(self, event, target, player, data)
        local targets = player.room:getOtherPlayers(player)
        if #targets > 0 then
            data.disresponsiveList = data.disresponsiveList or {}
            for _, p in ipairs(targets) do
                table.insertIfNeed(data.disresponsiveList, p)
            end
        end
    end,
})

ba__yingxiao:addEffect(fk.DetermineDamageCaused, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(ba__yingxiao.name) and data.from == player and data.to ~= player
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local damage = data.damage
        if target.hp <= player.hp then
            data.damage = math.floor(damage * 1.5)
        end
    end,
})

ba__yingxiao:addEffect(fk.TargetConfirmed, {
    anim_type = "defensive",
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(ba__yingxiao.name) and data.card and data.from ~= player
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        if data.from.dead or #room:askToDiscard(data.from, {
                min_num = 2,
                max_num = 2,
                include_equip = true,
                skill_name = ba__yingxiao.name,
                cancelable = true,
                pattern = ".|.|.|.|.|.",
                prompt = "#yingxiao_discard:" .. player.id,
            }) == 0 then
            data.nullified = true
        end
    end,
})

return ba__yingxiao
