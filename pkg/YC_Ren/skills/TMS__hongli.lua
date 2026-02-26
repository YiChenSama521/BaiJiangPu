local TMS__hongli = fk.CreateSkill {
  name = "TMS__hongli",
  tags = {Skill.Limited},
}
Fk:loadTranslationTable{
  ["TMS__hongli"] = "红利",
  [":TMS__hongli"] = "限定技，你可以大喊“得胜已是定局，你耳朵聋吗？”然后你印一张【诸葛连弩】（离开你的装备区前，销毁之）。",
  ["$TMS__hongli"] = "得胜已是定局，你耳朵聋么？",
  ["#TMS__hongli-active"] = "你可以印一张【诸葛连弩】。",
}

local YC = require "packages.BaiJiangPu.functions"

TMS__hongli:addEffect("active", {
  anim_type = "control",
  prompt = "#TMS__hongli-active",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:hasSkill(TMS__hongli.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = room:printCard("crossbow", Card.NoSuit,0)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, TMS__hongli.name, nil, true, player)
    room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
    --砸蛋 送花
    for i = 1, 3 do
      YC.zadan(player)
      room:delay(500)
    end
    room:delay(2500)
    for i = 1, 3 do
      YC.songhua(player)
      room:delay(2500)
    end
    --说话
    for _, p in ipairs(room:getOtherPlayers(player)) do
      p:chat("巨兽大人要释怀了吗😭😭😭！")
      room:doIndicate(p.id, { player.id })
    end
  end
})

return TMS__hongli
