local ba__shihou = fk.CreateSkill {
  name = "ba__shihou",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["ba__shihou"] = "食猴",
  [":ba__shihou"] = "持恒技，出牌阶段限一次，你可以选择1个“猴子”，吞食其所有技能，获得其体力上限。",
  ["#ba__shihou-active"] = "食猴：选择一名敌方角色，吞食其所有技能，获得其体力上限",
  ["#ba__shihou"] = "你可以吞食一个“猴子”",
}

ba__shihou:addEffect("active", {
  anim_type = "offensive",
  target_num = 1,
  prompt = "#ba__shihou",
  can_use = function(self, player)
    return player:hasSkill(ba__shihou.name) and player:usedSkillTimes(ba__shihou.name) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 0 and to_select ~= player and to_select.hp > 0 then
      return true
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local tos = effect.tos[1]
    room:changeMaxHp(player,tos.maxHp)
    room:recover{
      who = player,
      num = tos.hp,
      recoverBy = player,
      skillName = ba__shihou.name
    }
    local skills = {}
    for _, s in ipairs(tos.player_skills) do
      if s:isPlayerSkill(tos) then
        table.insertIfNeed(skills, s.name)
      end
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, true, false)
      room:handleAddLoseSkills(tos, "-"..table.concat(skills, "|-"), nil, true, false)
    end
    room:killPlayer({who = tos})
  end,
})

ba__shihou:addAI(Fk.Ltk.AI.newActiveStrategy{
  -- 出牌优先级：数值越大越早考虑
  use_priority = 10,
  -- 使用价值：用于粗略排序评估
  use_value = 10,
  -- 主动技AI核心：返回{子牌列表, 目标数组, 交互数据?}, 以及收益
  think = function(self, ai) -- 返回值将被convertThinkResult包装为req
    local player = ai.player -- 当前操作者
    local candidates = ai:getEnabledTargets() -- 当前面板可选目标
    candidates = candidates or {} -- 兜底，避免nil
    -- 仅考虑敌人；若无敌人可选则放弃
    local enemies = table.filter(candidates, function(p) -- 过滤敌人
      return ai:isEnemy(p) -- 明确敌我
    end)
    if #enemies == 0 then -- 没有合适目标
      return nil, -1 -- 不发动
    end
    -- 统计目标可被吞食的玩家技数量（近似评估长期收益）
    local function countStealableSkills(p) -- 计算玩家技数
      local n = 0 -- 计数器
      for _, s in ipairs(p.player_skills) do -- 遍历其技能
        if s:isPlayerSkill(p) then -- 仅统计属于其本人的玩家技
          n = n + 1 -- 计数+1
        end
      end
      return n -- 返回总数
    end
    -- 目标评分函数：越高越值得吞食
    local function score(p) -- 评估单个目标
      local skillN = countStealableSkills(p) -- 可吞食技能数
      local val = 0 -- 初始化分数
      val = val + 1000 -- 击杀敌人的基础收益
      val = val + p.maxHp * 60 -- 获得其体力上限的收益
      val = val + p.hp * 80 -- 立即回复等同其当前体力的收益
      val = val + skillN * 120 -- 吞食技能的潜在收益
      return val -- 返回评分
    end
    -- 从敌人中挑选评分最高者
    local best, bestVal = nil, -1e9 -- 最优目标与分数
    for _, p in ipairs(enemies) do -- 枚举敌人
      local v = score(p) -- 计算分数
      if (not best) or (v > bestVal) then -- 取最大值
        best, bestVal = p, v -- 更新最优
      end
    end
    if not best or bestVal <= 0 then -- 若不划算则不发动
      return nil, -1 -- 返回负收益
    end
    -- 组装返回：无子牌，单一目标
    local subcards = {} -- 本技能不需要选牌
    local targets = { best } -- 只选择评分最高的敌人
    return { subcards, targets, nil }, bestVal -- 返回选项与收益
  end, -- think结束
})

return ba__shihou
