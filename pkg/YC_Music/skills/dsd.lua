local dsd = fk.CreateSkill {
  name = "dsd",
}

dsd:addEffect("active", {
 can_use = Util.FalseFunc,
 on_use = function(self, room, effect)
 end,
})  

return dsd