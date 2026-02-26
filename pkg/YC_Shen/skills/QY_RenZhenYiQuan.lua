local renzhenyiquan = fk.CreateSkill({
  name = "renzhenyiquan",
  tags = {Skill.Permanent},
})

local YC_functions = require "packages.BaiJiangPu.functions"

Fk:loadTranslationTable{
  ["renzhenyiquan"] = "认真一拳",
  [":renzhenyiquan"] = "持恒技，出牌阶段，若你的体力值不为体力值上限，你可以失去1点体力，然后使所有其他角色失去所有技能并死亡。",
  ["#renzhenyiquan-ask"] = "认真一拳：你可以失去1点体力，然后使所有其他角色失去所有技能并死亡",
  ["@renzhenyiquan"] = "我投降，呜~呜~呜~",
}

renzhenyiquan:addEffect("active", {
  prompt = "#renzhenyiquan-ask",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:hasSkill(self) and player.hp ~= player.maxHp
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:loseHp(player, 1, self.name)
    -- 令目标失去所有技能
    for _, target in ipairs(room:getOtherPlayers(player)) do
      YC_functions.removeAllSkills(target, room, self.name)
    end
    -- 令目标死亡
    for _, target in ipairs(room:getOtherPlayers(player)) do
      room:killPlayer({
        who = target,
        skillName = self.name,
      })
    end
  end
})

return renzhenyiquan
