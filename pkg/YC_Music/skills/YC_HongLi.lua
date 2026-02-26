local YC_HongLi = fk.CreateSkill {
    name = "YC_HongLi",
    tags = { Skill.Permanent, Skill.Compulsory },
}
Fk:loadTranslationTable {
    ["YC_HongLi"] = "<font color='red'><b>逸晨的红利</font>",
    [":YC_HongLi"] = "<font color='red'><b>持恒技，锁定技，玩家专属技，<font color='red'>诸事皆必如其所愿</font></b></font>",
}
local hongliplayer = { "YiChenSama", "是共赏ya" }

--弃牌阶段不弃牌
YC_HongLi:addEffect(fk.EventPhaseChanging, {
    mute = true,
    global = true,
    priority = 13145201,
    can_trigger = function(self, event, target, player, data)
        return target == player and table.contains(hongliplayer, player._splayer:getScreenName()) and player:getMark("YC_Hongli") and data.phase == Player.Discard and math.random(1, 100) <= 25
    end,
    on_use = function(self, event, target, player, data)
        data.skipped = true
    end,
})
--摸牌阶段摸ak
YC_HongLi:addEffect(fk.BeforeDrawCard, {
    mute = true,
    global = true,
    priority = 13145202,
    can_trigger = function(self, event, target, player, data)
        return target == player and table.contains(hongliplayer, player._splayer:getScreenName()) and player:getMark("YC_Hongli") and math.random(1, 100) <= 50 and not player.room:isGameMode("hx__studpoker_mode")
    end,
    on_use = function(self, event, target, player, data)
        if math.random(1, 100) <= 25 then
            data.num = data.num + 1
        end
        local room = player.room
        if General.name == "liuyan" then
            local spear = room:getCardsFromPileByRule("spear", 1, "allPiles")
            room:obtainCard(player, spear, false, fk.ReasonPrey, player, YC_HongLi.name)
        else
            local crossbow = room:getCardsFromPileByRule("crossbow", 1, "allPiles")
            room:obtainCard(player, crossbow, false, fk.ReasonPrey, player, YC_HongLi.name)
        end
    end,
})
--过判定
YC_HongLi:addEffect(fk.StartJudge, {
    mute = true,
    global = true,
    priority = 13145203,
    can_trigger = function(self, event, target, player, data)
        return target == player and table.contains(hongliplayer, player._splayer:getScreenName()) and player:getMark("YC_Hongli")
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        if data.reason == "#eight_diagram_skill" then
            local ids = table.filter(room.draw_pile, function(id)
                return Fk:getCardById(id).color == Card.Red
            end)
            if #ids > 0 then
                local weapon = ids[math.random(1, #ids)]
                room:moveCards({
                    ids = { weapon },
                    from = player,
                    toArea = Card.DrawPile,
                    moveReason = fk.ReasonPut,
                    skillName = YC_HongLi.name,
                    moveVisible = false,
                })
            end
        elseif data.reason == "indulgence" and player.phase == Player.Judge then
            local ids = table.filter(room.draw_pile, function(id)
                return Fk:getCardById(id).suit == Card.Heart
            end)
            if #ids > 0 then
                local weapon = ids[math.random(1, #ids)]
                room:moveCards({
                    ids = { weapon },
                    from = player,
                    toArea = Card.DrawPile,
                    moveReason = fk.ReasonPut,
                    skillName = YC_HongLi.name,
                    moveVisible = false
                })
            end
        elseif data.reason == "supply_shortage" and player.phase == Player.Judge then
            local ids = table.filter(room.draw_pile, function(id)
                return Fk:getCardById(id).suit == Card.Club
            end)
            if #ids > 0 then
                local weapon = ids[math.random(1, #ids)]
                room:moveCards({
                    ids = { weapon },
                    from = player,
                    toArea = Card.DrawPile,
                    moveReason = fk.ReasonPut,
                    skillName = YC_HongLi.name,
                    moveVisible = false
                })
            end
        elseif data.reason == "lightning" then
            local ids = table.filter(room.draw_pile, function(id)
                return Fk:getCardById(id).suit ~= Card.Spade
            end)
            if #ids > 0 then
                local weapon = ids[math.random(1, #ids)]
                room:moveCards({
                    ids = { weapon },
                    from = player,
                    toArea = Card.DrawPile,
                    moveReason = fk.ReasonPut,
                    skillName = YC_HongLi.name,
                    moveVisible = true
                })
            end
        end
    end,
})
--受伤回复
YC_HongLi:addEffect(fk.Damaged, {
    mute = true,
    global = true,
    priority = 13145204,
    can_trigger = function(self, event, target, player, data)
        return target == player and table.contains(hongliplayer, player._splayer:getScreenName()) and player:getMark("YC_Hongli") and math.random(1, 100) <= 25
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        player.room:recover({
            who = player,
            num = 1,
            recoverBy = player,
            skillName = YC_HongLi.name,
        })
    end,
})

return YC_HongLi