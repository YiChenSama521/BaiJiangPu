local qc__huaxian = fk.CreateSkill({
  name = "qc__huaxian",
  tags = {Skill.Permanent, Skill.Compulsory},
})
Fk:loadTranslationTable{
  ["qc__huaxian"] = "画现",
  [":qc__huaxian"] = "永恒技，<a href='General_Skill'>共鸣技</a>，你的技能不能被取消发动且不会失效。"..
  "出牌阶段限一次，你可以执行一次“游戏开始时”的时机。",
  ["#qc__huaxian-active"] = "你可以发动【画现】，执行一次“游戏开始时”的时机。",
  ["General_Skill"] = "共鸣技，该技能仅限原武将牌上的角色才能发动。",
}
--永恒技实现，放置在最上方
qc__huaxian:addLoseEffect(function(self, player, is_death)
    player.room:handleAddLoseSkills(player, qc__huaxian.name, nil, false, true)
end)

qc__huaxian:addEffect("active", {
  anim_type = "control",
  prompt = "#qc__huaxian-active",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0 and player.general == "QC__huayaweiyan"
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local skills = table.map(table.filter(player.player_skills, function(skill) return skill:isPlayerSkill(player) end), function(s) return s.name end)
    for _, skill_name in ipairs(skills) do
      local skel = Fk.skill_skels[skill_name]
      if skel and #skel.effects > 0 then
        for _, skill in ipairs(skel.effects) do
          if skill:isInstanceOf(TriggerSkill) and skill.event == fk.GameStart then
            local function error_handler(err)
              local trace = debug.traceback()
              return tostring(err) .. "\n" .. trace
            end
            local event = fk.GameStart:new(room, player)
            local success, result = xpcall(function()
              return skill:doCost(event, player, player)
            end, error_handler)
          end
        end
      end
    end
  end,
})










return qc__huaxian