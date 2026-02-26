local ba__tiancai = fk.CreateSkill {
  name = "ba__tiancai",
  tag = Skill.Permanent,
}

Fk:loadTranslationTable{
  ["ba__tiancai"] = "天才",
  [":ba__tiancai"] = "持恒技，出牌阶段限一次，你可以随机获得一个<a href=':ba__tiancai_idea'>【主意】</a>。",
  ["#ba__tiancai"] = "你可以随机获得一个【主意】",
  [":ba__tiancai_idea"] = "好主意：1、随机获得一个天气效果；2、随机一名友方角色获得一个额外回合；3、弃置随机一名敌方角色所有区域的牌。"..
  "<br/>馊主意：1、随机失去一个天气效果；2、随机一名敌方角色获得一个额外回合；3、弃置随机一名友方角色所有区域的牌。",
  ["#ba__tiancai_good"] = "%from 想出了一个【好主意】！",
  ["#ba__tiancai_bad"] = "%from 想出了一个【馊主意】！",
  ["#ba__tiancai_weather_gain"] = "%from 想出了一个【好主意】，随机获得了一个天气效果：【%arg】",
  ["#ba__tiancai_weather_lost"] = "%from 想出了一个【馊主意】，随机失去了一个天气效果：【%arg】",
}

local Weathers = { "ba__wind", "ba__clouds", "ba__sun", "ba__lightning", "ba__thunder", "ba__ice" }

ba__tiancai:addEffect("active", {
  anim_type = "control",
  prompt = "#ba__tiancai",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:hasSkill(ba__tiancai.name) and player:usedSkillTimes(ba__tiancai.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local from = effect.from
    local is_good = math.random(1, 2) == 1
    local choice = math.random(1, 3)

    if is_good then
      room:sendLog { type = "#ba__tiancai_good", from = from.id ,toast = true}
      if choice == 1 then
        local banner = room:getBanner("@[:]ba__tianqimofang") or {}
        local available = table.filter(Weathers, function(w) return not table.contains(banner, w) end)
        if #available > 0 then
          local weather = table.random(available)
          table.insert(banner, weather)
          room:setBanner("@[:]ba__tianqimofang", banner)
          room:sendLog {
            type = "#ba__tiancai_weather_gain",
            from = from.id,
            arg = Fk:translate(weather),
            toast = true,
          }
        end
      elseif choice == 2 then
        local friends = table.filter(room:getAlivePlayers(), function(p) return from:isFriend(p) end)
        if #friends > 0 then
          local target = table.random(friends)
          target:gainAnExtraTurn(false, ba__tiancai.name)
        end
      elseif choice == 3 then
        local enemies = table.filter(room:getAlivePlayers(), function(p) return from:isEnemy(p) end)
        if #enemies > 0 then
          local target = table.random(enemies)
          local cards = target:getCardIds("hej")
          if #cards > 0 then
            room:throwCard(cards, ba__tiancai.name, target, target)
          end
        end
      end
    else
      -- 馊主意
      room:sendLog { type = "#ba__tiancai_bad", from = from.id, toast = true }
      if choice == 1 then
        local banner = room:getBanner("@[:]ba__tianqimofang") or {}
        if #banner > 0 then
          local index = math.random(1, #banner)
          local weather = table.remove(banner, index)
          room:setBanner("@[:]ba__tianqimofang", banner)
          room:sendLog {
            type = "#ba__tiancai_weather_lost",
            from = from.id,
            arg = Fk:translate(weather),
            toast = true,
          }
        end
      elseif choice == 2 then
        local enemies = table.filter(room:getAlivePlayers(), function(p) return from:isEnemy(p) end)
        if #enemies > 0 then
          local target = table.random(enemies)
          target:gainAnExtraTurn(false, ba__tiancai.name)
        end
      elseif choice == 3 then
        local friends = table.filter(room:getAlivePlayers(), function(p) return from:isFriend(p) end)
        if #friends > 0 then
          local target = table.random(friends)
          local cards = target:getCardIds("hej")
          if #cards > 0 then
            room:throwCard(cards, ba__tiancai.name, target, target)
          end
        end
      end
    end
  end
})

ba__tiancai:addAI(Fk.Ltk.AI.newActiveStrategy {
  use_priority = 8,
  use_value = 8,
  think = function(self, ai)
    local player = ai.player
    local room = player.room
    local banner = room:getBanner("@[:]ba__tianqimofang") or {}
    local function scoreGoodIdea()
      local val = 500
      local has_weather = #banner > 0
      local friends = table.filter(room:getAlivePlayers(), function(p) return player:isFriend(p) end)
      local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
      local best_extra_turn = 0
      for _, p in ipairs(friends) do
        if p.maxHp > best_extra_turn then
          best_extra_turn = p.maxHp
        end
      end
      local best_discard = 0
      for _, p in ipairs(enemies) do
        local card_count = #p:getCardIds("hej")
        if card_count > best_discard then
          best_discard = card_count
        end
      end
      local weather_gain_val = has_weather and 300 or 600
      local extra_turn_val = best_extra_turn * 50
      local discard_val = best_discard * 40
      return { weather_gain_val, extra_turn_val, discard_val }
    end
    local function scoreBadIdea()
      local val = -500
      local friends = table.filter(room:getAlivePlayers(), function(p) return player:isFriend(p) end)
      local enemies = table.filter(room:getAlivePlayers(), function(p) return player:isEnemy(p) end)
      local weather_loss_val = #banner > 0 and -300 or 0
      local enemy_extra_turn_val = -100
      local friend_discard_val = 0
      for _, p in ipairs(friends) do
        friend_discard_val = friend_discard_val - (#p:getCardIds("hej") * 30)
      end
      return { weather_loss_val, enemy_extra_turn_val, friend_discard_val }
    end
    local good_scores = scoreGoodIdea()
    local bad_scores = scoreBadIdea()
    local best_good = 1
    for i = 2, 3 do
      if good_scores[i] > good_scores[best_good] then
        best_good = i
      end
    end
    local best_bad = 1
    for i = 2, 3 do
      if bad_scores[i] > bad_scores[best_bad] then
        best_bad = i
      end
    end
    local good_val = good_scores[best_good]
    local bad_val = bad_scores[best_bad]
    if good_val + bad_val <= 0 then
      return nil, -1
    end
    local is_good = good_val >= bad_val
    local choice = is_good and best_good or best_bad
    local subcards = {}
    local targets = {}
    local extra = { is_good = is_good, choice = choice }
    return { subcards, targets, extra }, is_good and good_val or bad_val
  end
})

return ba__tiancai