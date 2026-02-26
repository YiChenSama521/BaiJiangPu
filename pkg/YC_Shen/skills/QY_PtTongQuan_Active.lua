local putongquan__active = fk.CreateSkill {
  name = "#putongquan__active",
}

Fk:loadTranslationTable {
  ["#putongquan__active"] = "普通拳",
}


putongquan__active:addEffect("active", {
  name = "#putongquan__active",
  interaction = function(self, player)
    local num = 18
    return UI.Spin { from = 1, to = num, default = num }
  end,
  target_num = 0,
  target_filter = Util.FalseFunc,
  card_num = 0,
  card_filter = Util.FalseFunc,
})

return putongquan__active
