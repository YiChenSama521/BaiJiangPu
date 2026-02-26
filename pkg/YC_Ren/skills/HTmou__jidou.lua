local HTmou__jidou = fk.CreateSkill({
    name = "HTmou__jidou",
})

Fk:loadTranslationTable {
    ["HTmou__jidou"] = "激斗",
    [":HTmou__jidou"] = "出牌阶段，你可以失去一点体力视为使用一张【决斗】；当你造成或受到【决斗】的伤害时，你可以摸一张牌。 ",
    ["#HTmou__jidou"] = "激斗：你可以失去一点体力视为使用一张【决斗】",
}
--出牌阶段，你可以失去一点体力视为使用一张【决斗】；
HTmou__jidou:addEffect("viewas", {
    anim_type = "offensive",
    mute_card = false,
    pattern = "duel",
    prompt = "#HTmou__jidou",
    card_filter = Util.FalseFunc,
    view_as = function(self, player, cards)
        local c = Fk:cloneCard("duel")
        c.skillName = self.name
        return c
    end,
    before_use = function(self, player, use)
        player.room:loseHp(player, 1, HTmou__jidou.name)
    end,
    enabled_at_play = function(self, player)
        return player.hp > 0
    end,
    enabled_at_response = function(self, player, response)
        return player.hp > 0 and not response and player.phase == Player.Play
    end,
})
--当你造成或受到【决斗】的伤害时，你可以摸一张牌。
HTmou__jidou:addEffect(fk.DamageCaused, {
    can_trigger = function(self, event, target, player, data)
        return target == player and data.card and data.card.trueName == "duel" and player:hasSkill(HTmou__jidou.name)
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        room:drawCards(player, 1, HTmou__jidou.name)
    end
})

HTmou__jidou:addEffect(fk.DamageInflicted, {
    can_trigger = function(self, event, target, player, data)
        return target == player and data.card and data.card.trueName == "duel" and player:hasSkill(HTmou__jidou.name)
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        room:drawCards(player, 1, HTmou__jidou.name)
    end
})

return HTmou__jidou
