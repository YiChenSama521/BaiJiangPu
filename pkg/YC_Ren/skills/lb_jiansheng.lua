local lb_jiansheng = fk.CreateSkill({
    name = "lb_jiansheng",
    tags = { Skill.Compulsory },
})

Fk:loadTranslationTable {
    ["lb_jiansheng"] = "剑圣",
    [":lb_jiansheng"] = "锁定技，你的回合内你使用第奇数次【杀】，此杀无法响应；使用第偶数次【杀】，此杀伤害+1。",
    ["@jiansheng-sha-turn"] = "出杀次数:",
}

---@class UseCardDataSpec
lb_jiansheng:addEffect(fk.CardUsing, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(lb_jiansheng.name) and data.card and data.card.trueName == "slash" and
            player.room.current == player
    end,
    on_use = function(self, event, target, player, data)
        player.room:addPlayerMark(player, "@jiansheng-sha-turn", 1)
        local SlashCount = player:getMark("@jiansheng-sha-turn")
        if SlashCount % 2 == 1 then
            -- 奇数次，无法响应
            data.disresponsiveList = data.disresponsiveList or {}
            for _, p in ipairs(player.room:getAllPlayers()) do
                table.insert(data.disresponsiveList, p)
            end
        else
            -- 偶数次，伤害+1
            data.additionalDamage = (data.additionalDamage or 0) + 1
        end
    end,
})

return lb_jiansheng
