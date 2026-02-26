local qss = fk.CreateSkill {
  name = "qss",
}

qss:addEffect("active", {
 can_use = Util.FalseFunc,
 on_use = function(self, room, effect)
 end,
})

return qss