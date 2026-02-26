local extension = Package:new("BaiJiangPu_items", Package.SkinPack)
extension.extensionName = "BaiJiangPu"

local YC = require "packages.coins-system.csfs"

YC.addItem({ id = "YC_YQS_ticket", name = "YC_YQS_ticket", icon = "packages/BaiJiangPu/image/items/YC_YQS_ticket.png", price = 1000, isSell = true })

YC.addItem({ id = "YiChen_TouGao", name = "YiChen_TouGao", icon = "packages/BaiJiangPu/image/items/YiChen_TouGao.png", price = 8888888, isSell = false })

Fk:loadTranslationTable{
    ["YiChen_TouGao"] = "定制武将",
    [":YiChen_TouGao"] = "花费8888888金币可以在逸晨包内定制一个武将",
    ["YC_YQS_ticket"] = "摇钱树门票",
    [":YC_YQS_ticket"] = "摇钱树模式专属的门票",
}

return extension