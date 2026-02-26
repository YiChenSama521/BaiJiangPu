local BX_sishi = fk.CreateSkill({
    name = "BX_sishi",
    tags = { Skill.Compulsory },
})

Fk:loadTranslationTable {
    ["BX_sishi"] = "死士",
    [":BX_sishi"] = "锁定技，每轮开始时，你令所有角色获得一张牌并观看其他所有角色的手牌并选择X张牌标记为“死士”，当“死士”进入弃牌堆时/对你为目标时，你可以获得之并对其造成1点伤害/无效并获得其1张牌（X为当前存活人数）。",
}

BX_sishi:addEffect(fk.RoundStart, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(BX_sishi.name)
    end,
    on_cost = Util.TrueFunc,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local X = room:getAlivePlayers()
        room.drawCards(X, X, 1, BX_sishi.name)
    end







})








return BX_sishi
