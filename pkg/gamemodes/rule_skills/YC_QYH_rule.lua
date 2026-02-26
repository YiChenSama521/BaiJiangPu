local YC_QYH_rule = fk.CreateSkill {
    name = "#YC_QYH_rule",
}

local CONFIG = {
    PHASE = {
        GUARDS = 1,            -- 阶段1：四大保安
        PROTECT = 2,           -- 阶段2：保护年兽
        ZODIAC = 3,            -- 阶段3：十二生肖
    },
    NIANSHOU = "YC__nianshou", -- 年兽的武将ID
    ZODIAC_WAVES = {
        -- { "YC__zishu",    "YC__chouniu", "YC__yinhu", "YC__maotu" },
        -- { "YC__chenlong", "YC__sishe",   "YC__wuma",  "YC__weiyang" },
        -- { "YC__shenhou",  "YC__youji",   "YC__xugou", "YC__haizhu" },
        { "liubei", "liubei", "liubei", "liubei" },
        { "liubei", "liubei", "liubei", "liubei" },
        { "liubei", "liubei", "liubei", "liubei" },
    }
}

-- 辅助函数：获取所有BOSS（包括死亡）
local function getBosses(room)
    return table.filter(room.players, function(p) return p.id < 0 end)
end

-- 辅助函数：获取存活BOSS
local function getAliveBosses(room)
    -- 使用 alive_players 确保获取的是当前存活的玩家
    return table.filter(room.alive_players, function(p) return p.id < 0 end)
end

-- 辅助函数：获取存活玩家
local function getAlivePlayers(room)
    return table.filter(room.alive_players, function(p) return p.id > 0 end)
end

-- 阶段2：开始
---@param room Room
local function startPhase2(room)
    room:setTag("YC_QYH_Phase", CONFIG.PHASE.PROTECT)
    room:sendLog { type = "#YC_QYH_Phase2_Start" }
    room:setBanner("@[:]YC_QYH_Info", "#YC_QYH_Phase2")
    room:doBroadcastNotify("ShowToast", "#YC_QYH_Phase2_Start") -- Debug Toast

    local bosses = getBosses(room)
    local nian = bosses[1] -- 选第一个BOSS作为年兽

    if nian then
        if nian.dead then room:revivePlayer(nian) end
        -- 切换武将为年兽
        room:changeHero(nian, CONFIG.NIANSHOU, true, false, false, true, true)
        room:setPlayerProperty(nian, "maxHp", 4)
        room:setPlayerProperty(nian, "hp", 4)
        room:setPlayerProperty(nian, "role", "renegade") -- 年兽改为内奸（保护对象）
        room:delay(1000)
        -- 记录当前轮数
        room:setTag("YC_QYH_Phase2_StartRound", room:getBanner("RoundCount"))
    end
end

-- 阶段3：刷新生肖BOSS
local function spawnZodiacWave(room, waveIndex)
    local wave = CONFIG.ZODIAC_WAVES[waveIndex]
    if not wave then return end

    local bosses = getBosses(room)
    for i, general_name in ipairs(wave) do
        local p = bosses[i]
        if p then
            if p.dead then room:revivePlayer(p) end
            -- 切换武将为生肖BOSS
            room:changeHero(p, general_name, true, false, false, true, true)
        end
    end
    room:doBroadcastNotify("ShowToast", "#YC_QYH_Phase3_Wave" .. waveIndex) -- Debug Toast
end

-- 阶段3：开始
local function startPhase3(room)
    room:setTag("YC_QYH_Phase", CONFIG.PHASE.ZODIAC)
    room:setTag("YC_QYH_ZodiacWave", 1)
    room:sendLog { type = "#YC_QYH_Phase3_Start" }
    room:setBanner("@[:]YC_QYH_Info", "#YC_QYH_Phase3")
    room:doBroadcastNotify("ShowToast", "#YC_QYH_Phase3_Start") -- Debug Toast

    spawnZodiacWave(room, 1)
end

-- 游戏开始处理
local function handleGameStart(room)
    room:setTag("YC_QYH_Phase", CONFIG.PHASE.GUARDS)
    room:setBanner("RoundCount", 1)
    room:setBanner("@[:]YC_QYH_Info", "#YC_QYH_Phase1")
    room:doBroadcastNotify("ShowToast", "#YC_QYH_GameStart_Phase1") -- Debug Toast
end

-- 死亡处理
---@param room Room
---@param player ServerPlayer
local function handleDeath(room, player)
    local phase = room:getTag("YC_QYH_Phase") or 0
    local alive_bosses = getAliveBosses(room)
    local alive_players = getAlivePlayers(room)

    if phase == CONFIG.PHASE.GUARDS then
        -- 阶段1：所有BOSS死亡 -> 进阶段2
        if #alive_bosses == 0 then
            startPhase2(room)
            -- 玩家阵营失败条件
        elseif #alive_players == 0 then
            room:gameOver("loyalist")
        end
    elseif phase == CONFIG.PHASE.PROTECT then
        -- 阶段2：年兽死亡 -> 玩家失败
        if player.general == CONFIG.NIANSHOU then
            room:gameOver("loyalist")
        end
        -- 阶段2：所有玩家死亡 -> 玩家失败
        if #alive_players == 0 then
            room:gameOver("loyalist")
        end
    elseif phase == CONFIG.PHASE.ZODIAC then
        -- 阶段3：当前波次BOSS全部死亡 -> 下一波 或 胜利
        if #alive_bosses == 0 then
            local wave = room:getTag("YC_QYH_ZodiacWave")
            if wave < 3 then
                room:setTag("YC_QYH_ZodiacWave", wave + 1)
                spawnZodiacWave(room, wave + 1)
            else
                -- 玩家获胜
                room:gameOver("rebel")
            end
        end
        -- 阶段3：所有玩家死亡 -> 玩家失败
        if #alive_players == 0 then
            room:gameOver("loyalist")
        end
    end
end

-- 回合开始处理（用于阶段2倒计时）
local function handleTurnStart(room, player)
    local phase = room:getTag("YC_QYH_Phase")
    if phase == CONFIG.PHASE.PROTECT then
        local startRound = room:getTag("YC_QYH_Phase2_StartRound")
        local currentRound = room:getBanner("RoundCount")
        local nian = getBosses(room)[1]

        -- 存活两轮后 -> 进阶段3
        if currentRound - startRound >= 2 then
            if nian and not nian.dead and nian.general == CONFIG.NIANSHOU then
                startPhase3(room)
            else
                room:gameOver("loyalist")
            end
        end
    end
end

YC_QYH_rule:addEffect(fk.GameStart, {
    can_refresh = function(self, event, target, player, data)
        return player.seat == 1
    end,
    on_refresh = function(self, event, target, player, data)
        handleGameStart(player.room)
    end
})

YC_QYH_rule:addEffect(fk.Death, {
    can_refresh = function(self, event, target, player, data)
        return target == player
    end,
    on_refresh = function(self, event, target, player, data)
        handleDeath(player.room, player)
    end
})

YC_QYH_rule:addEffect(fk.TurnStart, {
    can_refresh = function(self, event, target, player, data)
        return target == player
    end,
    on_refresh = function(self, event, target, player, data)
        handleTurnStart(player.room, player)
    end
})

return YC_QYH_rule
