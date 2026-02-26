local BX_qianzhen = fk.CreateSkill({
    name = "BX_qianzhen",
    tags = { Skill.Lord },
})

Fk:loadTranslationTable {
    ["BX_qianzhen"] = "潜镇",
    [":BX_qianzhen"] = "主公技，每回合限一次， 当其他角色使用【杀】指定你为目标时，其他晋/魏势力角色可弃置一张手牌，令此【杀】对你无效，然后你摸一张牌。",
    ["#BX_qianzhen-invoke"] = "潜镇：%dest 使用%arg，你可弃置一张手牌，令此【杀】对司马师无效，然后司马师摸一张牌。",
}

BX_qianzhen:addEffect(fk.TargetSpecifying, {
    can_trigger = function(self, event, target, player, data)
        return data.from == player and data.card and data.card.trueName == "slash" and player:hasSkill(BX_qianzhen.name) and
        player.kingdom == "wei" or player.kingdom == "jin"
    end,
    on_cost = function(self, event, target, player, data)
        local room = player.room
        local card = room:askToCards(player, {
            skill_name = BX_qianzhen.name,
            min_num = 1,
            max_num = 1,
            include_equip = false,
            prompt = "#BX_qianzhen-invoke::" .. target.id .. ":" .. data.card:toLogString(),
            cancelable = true,
        })
        if #card > 0 then
            event:setCostData(self, { tos = { target }, cards = card })
            return true
        end
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local cards = room:askToChooseCards(player, {
          target = player,
          min = 1,
          max = 1,
          flag = "he",
          skill_name = BX_qianzhen.name,
        })
        room:throwCard(cards, BX_qianzhen.name, player, player)
        data:cancelAllTarget()
        if not player.dead and data.card.color ~= Card.Black and not data.from:isProhibited(player, data.card) then
            data:addTarget(player)
        end
    end,
})

return BX_qianzhen
