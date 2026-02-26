local qc__wusheng = fk.CreateSkill({
    name = "qc__wusheng",
})
Fk:loadTranslationTable {
    ["qc__wusheng"] = "武圣",
    [":qc__wusheng"] = "你可以将一张红色牌当任意【杀】使用或打出，出牌阶段限两次，当你使用【杀】指定目标后，你摸2张牌。",
    ["#qc__wusheng"] = "出牌阶段限两次，你可以将一张红色牌当任意【杀】使用或打出。",

    ["$qc__wusheng1"] = "求不敌标关羽教程",
    ["$qc__wusheng2"] = "投降右上角",
    ["$qc__wusheng3"] = "能转人工吗？是真人吗？",
    ["$qc__wusheng4"] = "打不过标将是真人在玩吗？",
    ["$qc__wusheng5"] = "点右上角菜单，然后点投降会吗？",
    ["$qc__wusheng6"] = "求租将教程",
}
local voicenum = 1

qc__wusheng:addEffect("viewas", {
    anim_type = "offensive",
    pattern = "slash",
    prompt = "#qc__wusheng",
    handly_pile = true,
    interaction = function(self, player)
        local all_names = table.filter(Fk:getAllCardNames("b"), function(name)
            return Fk:cloneCard(name).trueName == "slash"
        end)
        local names = player:getViewAsCardNames(qc__wusheng.name, all_names)
        if #names == 0 then return end
        return UI.CardNameBox { choices = names, all_choices = all_names }
    end,
    card_filter = function(self, player, to_select, selected)
        return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
    end,
    view_as = function(self, player, cards)
        if #cards ~= 1 then return end
        local c = Fk:cloneCard("slash")
        c.skillName = qc__wusheng.name
        c:addSubcards(cards)
        return c
    end,
})

qc__wusheng:addEffect(fk.AfterCardTargetDeclared, {
    anim_type = "offensive",
    can_trigger = function(self, event, target, player, data)
        return data.from == player and player:hasSkill(qc__wusheng.name) and data.card.trueName == "slash"
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local room = player.room
        if player:getMark("qc__wusheng-phase") <= 1 then
            room:drawCards(player, 2, qc__wusheng.name)
            room:addPlayerMark(player, "qc__wusheng-phase", 1)
        end
        player:chat(Fk:translate("$qc__wusheng" .. voicenum))
        voicenum = voicenum + 1
        if voicenum > 6 then
            voicenum = 1
        end
        for _, p in pairs(data.tos) do
            player:chat(("$@Wine:%d"):format(p.id))
            room:delay(500)
            p:chat(("$@Shoe:%d"):format(player.id))
        end
    end,
})

return qc__wusheng
