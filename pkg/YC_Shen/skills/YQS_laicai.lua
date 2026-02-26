local yqs_laicai = fk.CreateSkill {
    name = "yqs_laicai",
    tags = { Skill.Compulsory, Skill.Permanent }
}

Fk:loadTranslationTable {
    ["yqs_laicai"] = "来财",
    ["@yqs_laicai"] = "<font color='red'>来财</font>",
    ["@yqs_bafang-round"] = "<font color='red'>八方</font>",
    [":yqs_laicai"] = "<font color='red'>摇钱神木，上汲九天珠玉之精，下凝万姓求富之志，乃玄坛真君布泽人间之枢机。</font>",
}

yqs_laicai:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, yqs_laicai.name, nil, false, true)
end)

yqs_laicai:addEffect(fk.RoundStart, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(self.name)
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local room = player.room
        room:addPlayerMark(player, "@yqs_laicai", 1)
        room:changeShield(player, 1)
    end,
})

yqs_laicai:addEffect(fk.EventPhaseStart,{
    can_trigger = function(self, event, target, player, data)
        return  target == player and player:hasSkill(self.name) and player:getMark("@yqs_laicai") >= 0
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        player.room:changeHp(player, player:getMark("@yqs_laicai"))
    end,
})

yqs_laicai:addEffect(fk.DrawNCards, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(self.name) and target == player and player:getMark("@yqs_laicai") >= 0
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        data.n = data.n + player:getMark("@yqs_laicai") * 4
    end,
})

yqs_laicai:addEffect(fk.DamageCaused, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(self.name) and target == player
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        data.damage = data.damage + player:getMark("@yqs_laicai")
    end,
})

yqs_laicai:addEffect(fk.Damaged, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(self.name) and target == player
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        player.room:addPlayerMark(player, "@yqs_bafang-round", 1)
        if player:getMark("@yqs_bafang-round") >= 8 then
            player.room:sendLog { type = "你激怒了神树！", toast = true }
            player.room.logic:breakTurn()
            player:gainAnExtraTurn(false, yqs_laicai.name)
        end
    end,
})


yqs_laicai:addEffect("targetmod", {
    bypass_times = function(self, player, skill, scope, card)
        return player:hasSkill(self.name) and card
    end,
})

return yqs_laicai
