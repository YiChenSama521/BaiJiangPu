local desc_YC_QYH = [[
  # 抢银行模式
  ______________________

  ## 阶段一：冲入（基本完成，还需要小怪）
  击败四大保安（狼、鹰、豹、熊）。

  ## 阶段二：控制（基本完成，还需要小怪以及年兽ai）
  在年兽的无差别攻击下存活两轮，并保证年兽存活。

  ## 阶段三：决战（基本完成，还需要十二生肖BOSS、小怪以及BOSS专属ai）
  击败十二生肖BOSS（共3波）。
<br/><font color='red' size = '20' >欢迎向YiChenSama投稿模式专属小怪/BOSS！</font>
<br/><font color='red' size = '20' >QQ联系方式：2319647741！</font>
]]

local YC_func1 = require "packages.BaiJiangPu.functions"

-- 抢银行模式游戏逻辑类
local QYH_getLogic = function()
    local QYH_logic = GameLogic:subclass("QYH_logic")

    function QYH_logic:initialize(room)
        GameLogic.initialize(self, room)
        self.role_table = {
            nil, nil, nil, nil,
            { "hidden", "hidden", "hidden", "hidden", "hidden" },
            { "hidden", "hidden", "hidden", "hidden", "hidden", "hidden" },
            { "hidden", "hidden", "hidden", "hidden", "hidden", "hidden", "hidden" },
            { "hidden", "hidden", "hidden", "hidden", "hidden", "hidden", "hidden", "hidden" },
        }
    end

    function QYH_logic:assignRoles()
        local room = self.room
        local players = room.players
        for _, p in ipairs(players) do
            if p.id > 0 then
                room:setPlayerProperty(p, "role", "rebel")
            else
                room:setPlayerProperty(p, "role", "loyalist")
            end
            room:setPlayerProperty(p, "role_shown", true)
        end
        room:setBanner("@[:]YC_QYH_Info", "#YC_QYH_Phase1")
    end

  function QYH_logic:adjustSeats()
    local player_circle = {}
    local room = self.room
    local players = self.room.players
    table.shuffle(players)
    for j = 1, #players do
      table.insert(player_circle, players[j])
    end
    self.room:arrangeSeats(player_circle)
    end

    -- 选择武将流程
    function QYH_logic:chooseGenerals()
        local room = self.room
        local generalNum = room:getSettings('generalNum') or 5
        room:setCurrent(room.players[1])

        local general_pool = Fk:getAllGenerals()
        local remove_general_pool = { -- 移除武将
        }

        if #general_pool < generalNum * 4 then -- 简单的数量检查
            room:sendLog { type = "#NoGeneralDraw", toast = true }
            return room:gameOver("draw")
        end

        -- AI 分配 (四大保安)
        local guards = { "ba__lang", "ba__ying", "ba__bao", "ba__xiong" }
        local ais = table.filter(room.players, function(p) return p.id < 0 and p.role == "loyalist" end)
        for i, p in ipairs(ais) do
            local gName = guards[i] or "shen__yaoqianshu"
            room:setPlayerGeneral(p, gName, true, true)
        end
        -- 玩家选将
        local players = table.filter(room.players, function(p) return p.id > 0 end)
    local generals = room:getNGenerals(#players * generalNum + 2)
    local req = Request:new(players, "AskForGeneral")
    req.timeout = self.room:getSettings('generalTimeout')
    for i, p in ipairs(players) do
      local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
      req:setData(p, { arg, 1 })
      req:setDefaultReply(p, { arg[1] })
    end
    req:ask()
    local selected = {}
    for _, p in ipairs(players) do
      local general_ret
      general_ret = req:getResult(p)[1]
      room:setPlayerGeneral(p, general_ret, true, true)
      table.insertIfNeed(selected, general_ret)
    end
    generals = table.filter(generals, function(g) return not table.contains(selected, g) end)
    room:returnToGeneralPile(generals)
    for _, g in ipairs(selected) do
      room:findGeneral(g)
    end
    room:askToChooseKingdom(players)

    for _, p in ipairs(players) do
      room:broadcastProperty(p, "general")
    end
    end

    return QYH_logic
end


-- if  then
--   winner = "lord+loyalist"
-- elseif  then
--   winner = "rebel+rebel_chief"
-- elseif  then
--   winner = "renegade"
-- else
--   winner = role
-- end


local QYH_mode = fk.CreateGameMode({
    name = "YC_QYH",
    minPlayer = 5,
    maxPlayer = 8,
    minComp = 4,
    logic = QYH_getLogic,
    rule = "#YC_QYH_rule",

})

Fk:loadTranslationTable {
    ["YC_QYH"] = "抢银行",
    [":YC_QYH"] = desc_YC_QYH,
    ["@[:]YC_QYH_Info"] = "抢银行",
    ["#YC_QYH_Phase1"] = "阶段一：冲入",
    [":#YC_QYH_Phase1"] = "击败四大保安（狼、鹰、豹、熊）。",
    ["#YC_QYH_GameStart_Phase1"] = "游戏开始，击败四大保安！",
    ["#YC_QYH_Phase2"] = "阶段二：控制",
    [":#YC_QYH_Phase2"] = "在年兽的无差别攻击下存活两轮，并保证年兽存活。",
    ["#YC_QYH_Phase2_Start"] = "阶段二开始！保护年兽！",
    ["#YC_QYH_Phase3"] = "阶段三：决战",
    [":#YC_QYH_Phase3"] = "击败十二生肖BOSS（共3波）。",
    ["#YC_QYH_Phase3_Start"] = "阶段三开始！决战十二生肖！",
    ["#YC_QYH_Phase3_Wave1"] = "第一波生肖降临！",
    ["#YC_QYH_Phase3_Wave2"] = "第二波生肖降临！",
    ["#YC_QYH_Phase3_Wave3"] = "第三波生肖降临！",
    ["#NoGeneralDraw"] = "开启的武将不足以进行游戏",
}

return QYH_mode
