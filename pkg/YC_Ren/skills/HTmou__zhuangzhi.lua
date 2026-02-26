local HTmou__zhuangzhi = fk.CreateSkill({
    name = "HTmou__zhuangzhi",
})

Fk:loadTranslationTable {
    ["HTmou__zhuangzhi"] = "壮志",
    [":HTmou__zhuangzhi"] = "当你进入濒死状态时，你可以弃置场上的一张装备牌，然后将体力值回复至1。",
    ["#HTmou__zhuangzhi-choose"] = "壮志：你可以弃置场上的一张装备牌，然后将体力值回复至1。",
}

HTmou__zhuangzhi:addEffect(fk.EnterDying, {
    can_trigger = function(self, event, target, player, data)
        return player == target and player:hasSkill(HTmou__zhuangzhi.name) and
            table.find(player.room.alive_players, function(p)
                return #p:getCardIds("e") > 0
            end)
    end,
    on_cost = function(self, event, target, player, data)
        local room = player.room
        local targets = table.filter(room.alive_players, function(p)
            return #p:getCardIds("e") > 0
        end)
        local to = room:askToChoosePlayers(player, {
            min_num = 1,
            max_num = 1,
            targets = targets,
            skill_name = HTmou__zhuangzhi.name,
            prompt = "#HTmou__zhuangzhi-choose",
            cancelable = true,
        })
        if #to > 0 then
            event:setCostData(self, { tos = to })
            return true
        end
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local to = event:getCostData(self).tos[1]
        local card = room:askToChooseCard(player, {
            target = to,
            flag = "e",
            skill_name = HTmou__zhuangzhi.name,
        })
        room:throwCard(card, HTmou__zhuangzhi.name, to, player)
        if not player.dead then
            -- 将体力值回复至1
            room:recover({
                who = player,
                num = 1 - player.hp,
                recoverBy = player,
                skillName = HTmou__zhuangzhi.name,
            })
        end
    end,
})

return HTmou__zhuangzhi
