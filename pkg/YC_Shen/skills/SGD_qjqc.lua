local sgd_qjqc = fk.CreateSkill({
    name = "sgd_qjqc",
    tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
    ["sgd_qjqc"] = "七进七出",
    [":sgd_qjqc"] = "永恒技，①你可以将一张牌当作任意无点数无花色的牌使用或打出。当你于回合外使用或打出牌时，你获得1枚“胆”标记并摸2张牌。你的手牌上限+X（X为”胆“标记数）。②你计算与其他角色的距离始终-x且与你距离为2以内的其他角色不能响应你使用的牌（x为你已损失的体力值）。且与你距离为2以内的其他角色不能响应你使用的牌（x为你已损失的体力值）。",
    ["@sgd_qjqc_dan"] = "胆",
    ["#sgd_qjqc"] = "七进七出",
    ["$sgd_qjqc1"] = "还不可以认输！",
    ["$sgd_qjqc2"] = "龙战于野，其血玄黄！",
    ["$sgd_qjqc3"] = "绝望中，仍存有一线生机！",
}

sgd_qjqc:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, sgd_qjqc.name, nil, false, true)
end)

sgd_qjqc:addEffect("viewas", {
    pattern = ".|.|.|.|.|basic",
    card_num = 1,
    prompt = "#sgd_qjqc",
    handly_pile = true,
    filter_pattern = {
        min_num = 1,
        max_num = 1,
        pattern = ".|.|.|.|.|basic,equip,trick|.",
    },
    interaction = function(self, player)
        local allCardNames = {}
        for _, id in ipairs(Fk:getAllCardIds()) do
            local card = Fk:getCardById(id)
            if not table.contains(allCardNames, card.name) and
                -- (card.trueName == "slash" or card.trueName == "jink" or
                --     card.trueName == "peach" or card.trueName == "analeptic") and
                    ((Fk.currentResponsePattern == nil and player:canUse(card)) or
                    (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)))
                    and not player:prohibitUse(card) then
                table.insert(allCardNames, card.name)
            end
        end
        return UI.ComboBox { choices = allCardNames }
    end,
    view_as = function(self, player, cards)
        local choice = self.interaction.data
        if not choice or #cards ~= 1 then return end
        -- 创建无点数无花色的基本牌
        local c = Fk:cloneCard(choice)
        c:addSubcards(cards)
        c.skillName = sgd_qjqc.name
        c.number = 0
        c.suit = Card.NoSuit
        c.color = Card.NoColor
        return c
        -- 出牌阶段 响应 始终可用
    end,
    enabled_at_play = function(self, player)
        return player:hasSkill(sgd_qjqc.name)
    end,
    enabled_at_response = function(self, player)
        return player:hasSkill(sgd_qjqc.name)
    end,
})
-- 添加回合外使用/打出牌时的效果
sgd_qjqc:addEffect(fk.CardUseFinished, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(sgd_qjqc.name) and player.room.current ~= player
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local room = player.room
        -- 获得1枚"胆"标记
        room:addPlayerMark(player, "@sgd_qjqc_dan", 1)
        -- 摸2张牌
        room:drawCards(player, 2, sgd_qjqc.name)
    end
})

sgd_qjqc:addEffect(fk.CardRespondFinished, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(sgd_qjqc.name) and player.room.current ~= player
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local room = player.room
        -- 获得1枚"胆"标记
        room:addPlayerMark(player, "@sgd_qjqc_dan", 1)
        -- 摸2张牌
        room:drawCards(player, 2, sgd_qjqc.name)
    end
})

-- 手牌上限+X（X为"胆"标记数）
sgd_qjqc:addEffect("maxcards", {
    correct_func = function(self, player)
        return player:getMark("@sgd_qjqc_dan") * 2
    end
})
-- 距离计算始终-X（X为已损失的体力值）
sgd_qjqc:addEffect("distance", {
    correct_func = function(from, to, player)
        if to:hasSkill(sgd_qjqc.name) then
            return -to:getLostHp()
        end
    end,
})
-- 与你距离为2以内的其他角色不能响应你使用的牌
sgd_qjqc:addEffect(fk.CardUsing, {
    anim_type = "offensive",
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(sgd_qjqc.name) and data.card
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local targets = table.filter(player.room:getOtherPlayers(player), function(p)
            return player:compareDistance(p, 2, "<=")
        end)
        if #targets > 0 then
            data.disresponsiveList = data.disresponsiveList or {}
            for _, p in ipairs(targets) do
                table.insertIfNeed(data.disresponsiveList, p)
            end
        end
    end,
})

return sgd_qjqc
