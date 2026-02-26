local prefix = "packages.BaiJiangPu.pkg."

local modes = Package:new("BaiJiangPu-gamemodes", Package.SpecialPack)
modes:loadSkillSkelsByPath("./packages/BaiJiangPu/pkg/gamemodes/rule_skills")

local path = "packages.BaiJiangPu.pkg.gamemodes."

modes:addGameMode(require (path .. "YC_YQS"))
modes:addGameMode(require (path .. "YC_QYH"))

local YC_Sheng = require (prefix.."YC_Sheng")
local YC_Shen = require (prefix.."YC_Shen")
local YC_Xian = require (prefix.."YC_Xian")
local YC_Lin = require (prefix.."YC_Lin")
local YC_Ren = require (prefix.."YC_Ren")
local YC_Hun = require (prefix.."YC_Hun")
local YC_Gui = require (prefix.."YC_Gui")
local YC_Yao = require (prefix.."YC_Yao")
local YC_Mo = require (prefix.."YC_Mo")

local YC_Coins = require (prefix.."YC_Coins")
local YC_Music = require (prefix.."YC_Music")

local YC_items = require (prefix .. "YC_items")

Fk:loadTranslationTable{
   ["BaiJiangPu"] = "百将谱",
   ["BaiJiangPu-gamemodes"] = "万象策",
}

return {
  modes,

  YC_Sheng,
  YC_Shen,
  YC_Xian,
  YC_Lin,
  YC_Ren,
  YC_Hun,
  YC_Gui,
  YC_Yao,
  YC_Mo,

  YC_Coins,
  YC_Music,

  YC_items,
}