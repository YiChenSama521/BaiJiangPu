local hl__chushan = fk.CreateSkill {
  name = "hl__chushan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["hl__chushan"] = "出山",
  [":hl__chushan"] = "锁定技，每轮开始时，你从随机八项技能中选择两项技能获得。",
  ["#hl__chushan-choose"] = "出山：请选择两个技能出战（右键或长按可查看技能描述）",
  ["@hl__chushan_skills"] = "",
}

hl__chushan:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hl__chushan.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generals = Fk:getGeneralsRandomly(8, nil, { "ba__wuming" })
    local skills = {}
    for _, general in ipairs(generals) do
      table.insertIfNeed(skills, table.random(general:getSkillNameList()))
    end

    data = {
      path = "/packages/utility/qml/ChooseSkillBox.qml",
      data = {
        skills, 2, 2, "#hl__chushan-choose", table.map(generals, Util.NameMapper)
      },
    }

    local req = Request:new(player, "CustomDialog")
    req:setData(player, data)
    req:setDefaultReply(player, table.random(skills, 2))
    req.focus_text = self.name
    req:ask()
    skills = req:getResult(player)

    if #skills > 0 then
      local realNames = table.map(skills, Util.TranslateMapper)
      room:setPlayerMark(player, "@hl__chushan_skills", "<font color='burlywood'>" .. table.concat(realNames, " ") .. "</font>")
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
    end
  end,
})

return hl__chushan
