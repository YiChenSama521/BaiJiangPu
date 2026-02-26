local qc__zhanming = fk.CreateSkill({
    name = "qc__zhanming",
    tags = { Skill.Permanent, Skill.Compulsory },
})

Fk:loadTranslationTable{
    ["qc__zhanming"] = "战鸣",
    [":qc__zhanming"] = "永恒技，出牌阶段，你可减少一名角色任意点【战力值】，然后令另一名角色增加相同点的【战力值】；你可以移去5点【战力值】，选择下面一项执行：<br/>1.令一名角色随机获得1个技能；<br/>2.令一名角色失去1个技能；<br/>3.获得场上的1个技能。",
    ["qc__zhanming_active"] = "战鸣",
    ["#qc__zhanming_active"] = "战鸣：移去/增加战力，或移去5点战力发动特殊效果",
    ["transfer"] = "转移战力",
    ["random_skill"] = "随机获技",
    ["lose_skill"] = "令其弃技",
    ["get_skill"] = "获得场上技能",
    ["#qc__zhanming_transfer_amount"] = "请选择转移的战力点数",
    ["#qc__zhanming_lose_choice"] = "请选择令其失去的技能",
    ["#qc__zhanming_get_choice"] = "请选择获得的技能",
    ["qc__zhanming_transfer_source"] = "减少战力",
    ["qc__zhanming_transfer_dest"] = "增加战力",
    ["qc__zhanming_target"] = "目标",
}

--永恒技实现，放置在最上方
qc__zhanming:addLoseEffect(function(self, player, is_death)
    local room = player.room
    room:handleAddLoseSkills(player, qc__zhanming.name, nil, false, true)
end)

qc__zhanming:addEffect("active", {
    anim_type = "offensive",
    prompt = function (self, player, selected_cards, selected_targets)
        if self.interaction.data == "transfer" then
            return "#qc__zhanming_active"
        else
            return "#qc__zhanming_active2"
        end
    end,
    interaction = function(self, player)
        local choices = {"transfer"}
        if player:getMark("@qc__zhanli") >= 5 then
            table.insert(choices, "random_skill")
            table.insert(choices, "lose_skill")
            table.insert(choices, "get_skill")
        end
        return UI.ComboBox { choices = choices, all_choices = { "transfer", "random_skill", "lose_skill", "get_skill" } }
    end,
    card_num = 0,
    card_filter = Util.FalseFunc,
    min_target_num = 1,
    max_target_num = 2,
    target_filter = function(self, player, to_select, selected)
        local choice = self.interaction.data
        if choice == "transfer" then
            if #selected == 0 then
                return to_select:getMark("@qc__zhanli") > 0
            else
                return true
            end
        elseif choice == "lose_skill" or choice == "get_skill" then
            return #to_select:getSkillNameList() > 0
        else
            return true
        end
    end,
    target_tip = function(self, _, to_select, selected, _, _, selectable, _)
        if self.interaction.data == "transfer" then
            if #selected == 0 then
                return "qc__zhanming_transfer_source"
            else
                return "qc__zhanming_transfer_dest"
            end
        end
        return "qc__zhanming_target"
    end,
    on_use = function(self, room, effect)
        local player = effect.from
        local choice = self.interaction.data
        local targets = effect.tos
        
        if choice == "transfer" then
            local source = targets[1]
            local dest = targets[2]
            local max_cp = source:getMark("@qc__zhanli")
            if max_cp == 0 then return end
            local amount = room:askToNumber(player, {
                min = 1, max = max_cp,
                skill_name = qc__zhanming.name,
                cancelable = true,
                prompt = "#qc__zhanming_transfer_amount",
            })
            if not amount then return end
            room:removePlayerMark(source, "@qc__zhanli", amount)
            room:addPlayerMark(dest, "@qc__zhanli", amount)
        elseif choice == "random_skill" then
            room:removePlayerMark(player, "@qc__zhanli", 5)
            local target = targets[1]
            local generals = Fk.generals
            local keys = {}
            for k in pairs(generals) do table.insert(keys, k) end
            if #keys > 0 then
                local random_general = generals[keys[math.random(#keys)]]
                local skills = random_general:getSkillNameList(true)
                if #skills > 0 then
                    local skill = skills[math.random(#skills)]
                    room:handleAddLoseSkills(target, skill, nil, false, true)
                end
            end
        elseif choice == "lose_skill" then
            room:addPlayerMark(player, "@qc__zhanli", -5)
            local target = targets[1]
            local skills = target:getSkillNameList()
            if #skills > 0 then
                local skill = room:askToChoice(player, {
                  choices = skills,
                  skill_name = qc__zhanming.name,
                })
                if skill then
                    room:handleAddLoseSkills(target, "-"..skill, nil, false, true)
                end
            end
        elseif choice == "get_skill" then
            room:addPlayerMark(player, "@qc__zhanli", -5)
            local target = targets[1]
            local skills = target:getSkillNameList()
            if #skills > 0 then
                local skill = room:askToChoice(player, {
                  choices = skills,
                  skill_name = qc__zhanming.name,
                })
                if skill then
                    room:handleAddLoseSkills(player, skill, nil, false, true)
                end
            end
        end
    end,
})

return qc__zhanming
