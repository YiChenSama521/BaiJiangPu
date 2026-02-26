local YC_YQS_shop = fk.CreateSkill {
  name = "YC_YQS_shop&",
  mode_skill = true,
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["YC_YQS_shop&"] = "商店",
  [":YC_YQS_shop&"] = "使用金币展示2张卡牌和6个随机技能进行购买，刷新需要10X金币，购买技能需100X金币，卡牌免费（X为游戏难度）",
  ["#YC_YQS_shop-invoke"] = "使用金币展示2张卡牌和6个随机技能进行购买，刷新需要 %arg 金币，购买技能需 %arg2 金币，卡牌免费",
  ["YC_YQS_shop"] = "商店",
  ["#YC_YQS_shop"] = "商店：请选择要购买的能力",
  ["#YC_YQS_current"] = "当前持有：%arg",
  ["YC_YQS_shop_gold"] = "金币",
  ["YC_YQS_shop_refresh"] = "刷新",
  ["YC_YQS_shop_ok"] = "完成购买",
  ["YC_YQS_shop_cancel"] = "结束购买",
  ["#YC_YQS_Change_Log"] = "%arg %arg2 了 %arg3 金币",
}

local YC_functions = require "packages.BaiJiangPu.functions"

local YC_YQSUtil = {}

--- 改变玩家金币
---@param player ServerPlayer
---@param num integer
function YC_YQSUtil:ChangePlayerMoney(player, num)
  if num ~= 0 and player.id > 0 then
    YC_functions.ChangePlayerMoney(player, num)
    player.room:setPlayerMark(player, "YC_YQS_shop_gold", player:getMark("YC_YQS_shop_gold") + num)
  end
end

---@param player ServerPlayer
function YC_YQSUtil:generateShop(player, allSkills)
  local data = player:getTableMark("YC_YQS_shop_items")
  local skill_num = 6
  local card_num = 2

  local p_skills = table.map(player.player_skills, Util.NameMapper)

  local allcards = {}
  for _, id in ipairs(Fk:getAllCardIds()) do
    local card = Fk:getCardById(id, true)
    table.insert(allcards, { 0, card.name, card.number, { card.suit } })
  end

  table.shuffle(allSkills)

  local skills = table.filter(allSkills, function(s) return not table.contains(p_skills, s[2]) end)

  local cards = table.random(allcards, card_num)
  skills = table.random(skills, skill_num)

  for _, card in ipairs(cards) do
    table.insert(data, { "card", card[1], card[2], card[3], table.random(card[4]) })
  end
  for _, s in ipairs(skills) do
    table.insert(data, { "skill", table.unpack(s) })
  end
  return data
end

--- 打开商店
---@param player ServerPlayer
local shopping = function(player, allSkills)
  local room = player.room
  local data, shop_items
  local ifbreak = false
  for i = 1, 49 do
    if ifbreak then break end
    local diff = room:getSettings("YQS_Difficulty") or 1
    local req = Request:new({ player }, "CustomDialog")
    req.focus_text = "YC_YQS_shop"
    if i == 1 then
      data = YC_YQSUtil:generateShop(player, allSkills)
      shop_items = data
    else
      data = shop_items
    end
    room:setPlayerMark(player, "YC_YQS_shop_items", 0)
    req:setData(player, {
      path = "packages/BaiJiangPu/qml/RougeShop.qml",
      data = {items = data, refresh_cost = 10 * diff},
    })
    req:ask()
    local result = req:getResult(player)
    local diff = player.room:getSettings("YQS_Difficulty") or 1
    if result == "" then
      ifbreak = true
    else
      result = json.decode(result)
      local ret, refresh_count = result[2], result[1]
      if refresh_count == -10 then
        YC_YQSUtil:ChangePlayerMoney(player, -10 * diff)
        shop_items = YC_YQSUtil:generateShop(player, allSkills)
      end
      for _, dat in ipairs(ret) do
        if dat[1] == "skill" then
          YC_YQSUtil:ChangePlayerMoney(player, -100 * diff)
          room:handleAddLoseSkills(player, dat[3], nil, false)
          for index, value in ipairs(shop_items) do
            if value[3] == dat[3] then
              table.removeOne(shop_items, value)
              break
            end
          end
        elseif dat[1] == "card" then
          local card = room:printCard(dat[3], dat[5], dat[4])
          table.removeOne(shop_items, dat)
          room:obtainCard(player, card, true, fk.ReasonJustMove, nil, "#YC_YQS_rule&", MarkEnum.DestructIntoDiscard)
          for index, value in ipairs(shop_items) do
            if value[3] == dat[3] then
              table.removeOne(shop_items, value)
              break
            end
          end
        end
      end
    end
  end
end

YC_YQS_shop:addEffect("active", {
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_num = 0,
  target_num = 0,
  prompt = function (self, player, selected_cards, selected_targets)
    local diff = Fk:currentRoom():getSettings("YQS_Difficulty") or 1
    return "#YC_YQS_shop-invoke:::"..(10 * diff)..":"..(100 * diff)
  end,
  on_use = function(self, room, effect)
    local gold = YC_functions.ChangePlayerMoney(effect.from, 0)
    room:setPlayerMark(effect.from, "YC_YQS_shop_gold", gold)

    local black_pkgs = {
      "contribution", "fate", "RoyalNavy", "SakuraEmpire", "EagleUnion", "yyfy_token", "evoltruster", "ultimate", "deify"
    }
    local black_generals = {
      "ol__simashi",
    }
    local black_skills = {

    }

    local allSkills = {}
    local diff = room:getSettings("YQS_Difficulty") or 1
    for _, general in pairs(Fk.generals) do
      if not general.hidden and not general.total_hidden and not table.contains(black_generals, general.name) and not table.contains(black_pkgs, general.package.name) then
        for _, skillName in ipairs(general:getSkillNameList()) do
          local s = Fk.skills[skillName]
          if not table.contains(black_skills, skillName) and not skillName:startsWith("#") and
              not skillName:endsWith("&") and not s:isEquipmentSkill() and not s.cardSkill and s:isPlayerSkill() then
            table.insertIfNeed(allSkills, { 100 * diff, skillName })
          end
        end
      end
    end

    shopping(effect.from, allSkills)
  end
})

return YC_YQS_shop
