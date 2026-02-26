local TMS__bingqi = fk.CreateSkill{
  name = "TMS__bingqi",
}
Fk:loadTranslationTable{
  ["TMS__bingqi"] = "兵奇",
  [":TMS__bingqi"] = "出牌阶段，每种花色各限一次，你可以将红色牌当【无中生有】或【顺手牵羊】使用，黑色牌当【无懈可击】或【奇正相生】使用或打出。",
  ["#TMS__bingqi"] = "兵奇：将手牌当【无中生有】/【顺手牵羊】/【无懈可击】/【奇正相生】使用或打出",
}

local function suitUsed(player, cardId)
  local suit = Fk:getCardById(cardId):getSuitString()
  return suit ~= "" and player:getMark("TMS__bingqi_" .. suit .. "-phase") > 0
end

local function addSuitMark(player, cardId)
  local suit = Fk:getCardById(cardId):getSuitString()
  if suit ~= "" then
    player.room:addPlayerMark(player, "TMS__bingqi_" .. suit .. "-phase", 1)
  end
end

local redChoices = {"ex_nihilo", "snatch"}
local blackChoices = {"nullification", "raid_and_frontal_attack"}
local allChoices = {"ex_nihilo", "snatch", "nullification", "raid_and_frontal_attack"}

TMS__bingqi:addEffect("viewas", {
  anim_type = "control",
  pattern = "ex_nihilo,snatch,nullification,raid_and_frontal_attack",
  prompt = "#TMS__bingqi",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    if not table.contains(player:getHandlyIds(), to_select) then return false end
    if suitUsed(player, to_select) then return false end

    local choices
    if card.color == Card.Red then
      choices = redChoices
    elseif card.color == Card.Black then
      if Fk.currentResponsePattern then
        return Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard("nullification"))
      end
      choices = blackChoices
    else
      return false
    end
    return #player:getViewAsCardNames(TMS__bingqi.name, choices, {to_select}) > 0
  end,
  interaction = function(self, player)
    local choices = {}
    if Fk.currentResponsePattern then
      if Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard("nullification")) then
        choices = {"nullification"}
      end
    else
      choices = player:getViewAsCardNames(TMS__bingqi.name, allChoices)
    end
    if #choices > 0 then
      return UI.CardNameBox { choices = choices, all_choices = allChoices }
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local c = Fk:getCardById(cards[1])
    if table.contains(redChoices, self.interaction.data) and c.color ~= Card.Red then return end
    if table.contains(blackChoices, self.interaction.data) and c.color ~= Card.Black then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = TMS__bingqi.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    if use.card and #use.card.subcards > 0 then
      addSuitMark(player, use.card.subcards[1])
    end
  end,
  enabled_at_play = function(self, player)
    for _, id in ipairs(player:getHandlyIds()) do
      local c = Fk:getCardById(id)
      if not suitUsed(player, id) then
        if c.color == Card.Red and #player:getViewAsCardNames(TMS__bingqi.name, redChoices, {id}) > 0 then
          return true
        end
        if c.color == Card.Black and #player:getViewAsCardNames(TMS__bingqi.name, blackChoices, {id}) > 0 then
          return true
        end
      end
    end
    return false
  end,
  enabled_at_response = function(self, player, response)
    if response then return false end
    if not Exppattern:Parse(Fk.currentResponsePattern or ""):match(Fk:cloneCard("nullification")) then
      return false
    end
    for _, id in ipairs(player:getHandlyIds()) do
      local c = Fk:getCardById(id)
      if c.color == Card.Black and not suitUsed(player, id) then
        return true
      end
    end
    return false
  end,
})

return TMS__bingqi
