local csfs = require "packages.coins-system.csfs"
local Utility = require "packages.glory_days.utility"
local YC = require "packages.BaiJiangPu.functions"

local YC_City_Hunter = fk.CreateSkill {
  name = "YC_City_Hunter",
  tags = { Skill.Permanent, Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["YC_City_Hunter"] = "City Hunter",
  [":YC_City_Hunter"] = "City Hunter",
}

YC_City_Hunter:addEffect("active", {
  can_trigger = function(self, event, target, player, data)
    return player._splayer:getScreenName() == "YiChenSama"
  end,
  can_use = function(self, player)
    return true
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    -- 获取指定武将列表
    local all_generals = {
      "shen__wuhushangjiang",
      "evol__noa",
      "hxgod__doro",
      "YM_xifangersheng",
      "rfzy__ruizi",
      "ba__lang",
      "kaman_teshu__guansuo",
    }

    local req = Request:new({ player }, "CustomDialog")
    req.focus_text = "YC_City_Hunter"
    req:setData(player, {
      path = "packages/BaiJiangPu/qml/YC_City_Hunter.qml",
      data = {
        generals = all_generals,
        gold = player:getGlobalSaveState("CS_System_Data") and player:getGlobalSaveState("CS_System_Data").gold or 0,
        shuaidian = player:getGlobalSaveState("glory_days") and
        player:getGlobalSaveState("glory_days")["glory_days_shuaidian"] or 0,
      },
    })
    req:ask()

    local result = req:getResult(player)
    if result and result ~= "" then
      local data = json.decode(result)
      -- 修改金币
      if data.goldChange and data.goldChange ~= 0 then
        csfs.ChangePlayerMoney(player, data.goldChange)
      end
      -- 修改帅点
      if data.shuaidianChange and data.shuaidianChange ~= 0 then
        Utility.changePlayerRank(room, player, data.shuaidianChange)
      end
      -- 修改武将
      if data.newGeneral and data.newGeneral ~= "" and data.newGeneral ~= player.general then
        room:changeHero(player, data.newGeneral, false, false, true)
      end
    end
  end
})

return YC_City_Hunter
