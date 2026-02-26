local youji = fk.CreateSkill{
  name = "YC__youji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["YC__youji"] = "酉鸡",
  [":YC__youji"] = "锁定技，摸牌阶段，你多摸X张牌（X为游戏轮数且至多为5）。",

  ["$YC__youji"] = "鸡豚之息，虽微渐厚。",
}

youji:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  on_use = function(self, event, target, player, data)
    data.n = data.n + math.min(5, player.room:getBanner("RoundCount"))
  end,
})

return youji
