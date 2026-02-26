local desc_YC_YQS = [[
  # 摇钱树模式简介
  ______________________

  ## 模式特色

  摇钱树模式是一个获取金币的模式，玩家需要在存活的情况下对BOSS造成尽可能高的伤害！

  ## 游戏规则

  玩家独自挑战摇钱树BOSS，通过造成伤害来积累金币！
  1张门票1000金币，请勿在选将界面投降，以免造成不必要的损失！！！
  只有选将界面退出才不会消耗门票哦
  ## 特殊机制
  <br/><font color='red'> BOSS血量：摇钱树BOSS拥有88点血量，需要玩家在尽可能不受到伤害的情况下持续对BOSS进行输出；</font>

  <br/><font color='green'> 难度系统：难度会影响金币获取倍率（1到10倍）及BOSS伤害（1难度为1倍伤害，10难度为10倍伤害）；</font>

  <br/><font color='blue'> 金币计算：对局结束后结算金币和门票，金币总量 =（造成伤害*100 - 受到伤害*50）* 难度（向下取整）；</font>

  <br/><font color='red' size = '20' >开启自由选将请勿进入游戏！！！</font>
  <br/><font color='red' size = '20' >开启自由选将请勿进入游戏！！！</font>
  <br/><font color='red' size = '20' >开启自由选将请勿进入游戏！！！</font>
]]

local whitelist = { "standard", "standard_cards", "maneuvering", "standard_ex_cards" }

local YC_functions = require "packages.BaiJiangPu.functions"

-- 摇钱树模式游戏逻辑类
local YC_getLogic = function()
  -- 创建摇钱树逻辑类，继承自GameLogic
  local YC_logic = GameLogic:subclass("YC_logic")
  function YC_logic:initialize(room)
    GameLogic.initialize(self, room)
    self.role_table = { nil, { "lord", "rebel" } }
  end

  -- 分配角色身份
  function YC_logic:assignRoles()
    local room = self.room
    local n = #room.players
    local roles = self.role_table[n]
    table.shuffle(roles)
    -- 设置模式横幅
    room:setBanner("@[:]YQSmode", "#YQS-intro")
    local players = room.players
    local owner = table.filter(players, function(p) return p.id > 0 end)[1]
    local ai = table.filter(players, function(p) return p.id < 0 end)[1]
    ai.role = "rebel"
    owner.role = "lord"
    for _, p in ipairs(players) do
      room:broadcastProperty(p, "role")
      room:setPlayerProperty(p, "role_shown", true)
    end
  end

  -- 选择武将流程
  function YC_logic:chooseGenerals()
    local room = self.room
    local generalNum = room:getSettings('generalNum') or 3
    local players = room.players
    local general_pool = {
      "yi__liubei",
    }
    local remove_general_pool = { -- 移除武将
      "liubei", "tw__caoang", "tw__xiahouba", "tw__zumao", "tw__caohong", "tw__maliang", "tw__dingfeng",
      "nos__zhuzhi", "nos__caoxiu", "nos__zhuhuan", "nos__chenqun", "nos__liru", "nos__fuhuanghou", "nos__fazheng",
      "nos__xushu", "nos__lingtong", "nos__wangyi", "nos__madai", "nos__guanxingzhangbao", "nos__handang",
      "nos__caochong", "nos__zhuran", "anjiang",
    }
    local whiteExtension = { "standard", "yj" }
    for _, package in pairs(Fk.packages) do
      if table.contains(whiteExtension, package.extensionName) then
        table.insertIfNeed(whitelist, package.name)
        for _, general in ipairs(package.generals) do
          if not table.contains(remove_general_pool, general.name) and not general.hidden and not general.total_hidden then
            table.insertIfNeed(general_pool, general.name)
          end
        end
      end
    end
    local all_generals = table.random(general_pool, generalNum)
    if #all_generals < generalNum then
      room:sendLog {
        type = "#NoGeneralDraw",
        toast = true,
      }
      room:gameOver("")
    end
    -- 获取主公玩家
    local lord = room:getLord()
    if not lord then
      room:setCurrent(players[1])
      room:gameOver("")
    else
      room:setCurrent(lord)
    end

    local owner = table.filter(players, function(p) return p.id > 0 end)[1]
    local diff = room:getSettings("YQS_Difficulty") or 1
    local items = owner:getGlobalSaveState("coins_System_items") or {}
    local ticket = items["YC_YQS_ticket"] or 0
    if ticket < diff then
        room:sendLog { type = "你的门票不足，请到金币系统购买，游戏结束", toast = true }
        room:gameOver("")
    else
      room:sendLog { type = "#YQS_Ticket", toast = true, arg = ticket, arg2 = diff }
      room:setBanner("YC_YQS_rule_finished", ticket)
    end

    if room:getSettings("enableFreeAssign") then
      room:sendLog { type = "#YQS_enableFreeAssign", toast = true }
      YC_functions.ChangePlayerMoney(owner, -100)
      room:gameOver("")
    end

    local nonlord = table.filter(players, function(p) return p.id > 0 end)
    local ai = table.filter(players, function(p) return p.id < 0 end)
    for _, p in ipairs(ai) do
      room:setPlayerGeneral(p, "shen__yaoqianshu", true, true)
    end
    local req = room:askToMiniGame(nonlord, {
      skill_name = "AskForGeneral",
      game_type = "YC_YQS_noFreeChooseGeneral",
      data_table = {
        [nonlord[1].id] = {
          cards = all_generals,
          num = 1, extra = {n = 1},
          type = "askForGeneralsChosen",
        },
      },
      timeout = self.room:getSettings("generalTimeout"),
    })
    for _, p in ipairs(nonlord) do
      local result = req:getResult(p)
      local general, deputy = result[1], result[2]
      room:setPlayerGeneral(p, general, true, true)
    end
    room:askToChooseKingdom(players)
  end

  function YC_logic:attachSkillToPlayers()
    local room = self.room
    local addRoleModSkills = function(player, skillName)
      local skill = Fk.skills[skillName]
      if not skill then
        fk.qCritical("Skill: " .. skillName .. " doesn't exist!")
        return
      end
      if skill:hasTag(Skill.Lord) then
        return
      end
      if skill:hasTag(Skill.AttachedKingdom) and not table.contains(skill:getSkeleton().attached_kingdom, player.kingdom) then
        return
      end
      room:handleAddLoseSkills(player, skillName, nil, false)
    end
    for _, p in ipairs(room.alive_players) do
      for _, s in ipairs(Fk.generals[p.general]:getSkillNameList(false)) do
        addRoleModSkills(p, s)
      end
      if p.id > 0 then
        room:handleAddLoseSkills(p, "YC_YQS_shop&", nil, false)
      end
    end
  end

  return YC_logic
end

local YC_mode = fk.CreateGameMode({
  name = "YC_YQS",
  minPlayer = 2,
  maxPlayer = 2,
  minComp = 1,
  logic = YC_getLogic,
  rule = "#YC_YQS_rule&",
  whitelist = whitelist,
  build_draw_pile = function(self)
    local draw_pile, void = GameMode.buildDrawPile(self)
    local room = Fk:currentRoom()
    local num = (room:getSettings("YQS_morePile") or 0) - 1 -- 复制多少份牌堆

    for i = #draw_pile, 1, -1 do
      if num <= 0 then break end
      local id = draw_pile[i]
      local card = Fk:getCardById(id)
      for n = 1, num do
        local Card = AbstractRoom.printCard(room, card.name, card.suit, card.number)
        table.insert(draw_pile, Card.id)
      end
    end

    return draw_pile, void
  end,
  surrender_func = function(self, playedTime)
    return { { text = "time limitation: 1 s", passed = playedTime >= 1 } }
  end,
})

local W = require 'ui_emu.preferences'
YC_mode.ui_settings = {
  W.PreferenceGroup {
    title = "Properties_YQS_role",
    W.SpinRow {
      _settingsKey = "YQS_Difficulty",
      title = "YQS_Difficulty_settings",
      from = 1,
      to = 10,
    },
    W.SpinRow {
      _settingsKey = "YQS_morePile",
      title = "YQS_morePile_settings",
      from = 1,
      to = 10,
    },
  },
}

Fk:addMiniGame {
  name = "YC_YQS_noFreeChooseGeneral",
  qml_path = "packages/BaiJiangPu/qml/ChooseGeneralWithCanChange",
  default_choice = function(player, data) --默认值
    return table.slice(data.cards, 1, data.num + 1)
  end,
  update_func = function(player, data)
    player:doNotify("UpdateMiniGame", data)
  end,
}

-- 加载翻译表
Fk:loadTranslationTable {
  ["YC_YQS"] = "摇钱树",
  [":YC_YQS"] = desc_YC_YQS,
  ["@[:]YQSmode"] = "摇钱树",
  ["#YQS-intro"] = "介绍",
  [":#YQS-intro"] = [[
  <br/> 特殊机制
  <br/><font color='red'> BOSS血量：摇钱树BOSS拥有88点血量，需要玩家在尽可能不受到伤害的情况下持续对BOSS进行输出；</font>
  <br/><font color='green'> 难度系统：难度会影响金币获取倍率（1x到10x）及BOSS伤害（1难度为1倍伤害，10难度为10倍伤害）；</font>
  <br/><font color='blue'> 金币计算：对局结束后结算金币和门票，金币总量 =（造成伤害*100 - 受到伤害*50）* 难度（向下取整）；</font>]],
  ["Properties_YQS_role"] = "摇钱树模式设置",
  ["YQS_Difficulty_settings"] = "难度设置",
  ["help: YQS_Difficulty_settings"] = "影响最终获得的金币数和每次消耗的门票数",
  ["YQS_morePile_settings"] = "牌堆翻倍",
  ["help: YQS_morePile_settings"] = "默认1倍至多10倍",

  ["#YQS_enableFreeAssign"] = "你开启了自由选将！扣除100金币，游戏结束！！！",
  ["#YQS_noTicket"] = "你的门票不足，需要%arg张才能开启对局，是否花费%arg2金币补齐门票？（开启自由选将请勿点击确定）",
  ["#YQS_Ticket"] = "你当前有%arg张门票，允许开局，本局难度为%arg2，游戏结束时将消耗%arg2张门票",
}

return YC_mode
