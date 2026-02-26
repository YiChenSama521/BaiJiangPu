local YAN__xiongjun = fk.CreateSkill({ name = "YAN__xiongjun" })

Fk:loadTranslationTable {
    ["YAN__xiongjun"] = "凶军",
    [":YAN__xiongjun"] = "出牌阶段，你可对一名角色造成一点伤害并摸一张牌，每名角色限一次。",
}

YAN__xiongjun:addEffect("active", {
    target_num = 1,
    card_num = 0,
    card_filter = Util.FalseFunc,
    target_filter = function(self, player, to_select, selected)
        return #selected == 0 and not table.contains(player:getTableMark("YAN__xiongjun"), to_select.id)
    end,
    on_use = function(self, room, effect)
        local player = effect.from
        local target = effect.tos[1]
         room:addTableMarkIfNeed(player, "YAN__xiongjun", target.id)
        room:damage {
            from = player,
            to = target,
            damage = 1,
            skillName = YAN__xiongjun.name,
        }
        room:drawCards(player, 1, YAN__xiongjun.name)
    end,
})

return YAN__xiongjun
