local qc__huajing = fk.CreateSkill({
    name = "qc__huajing",
    tags = { Skill.Permanent, Skill.Compulsory },
})

local U = require "packages.utility.utility"

Fk:loadTranslationTable {
    ["qc__huajing"] = "画境",
    [":qc__huajing"] = "永恒技，<a href='General_Skill'>共鸣技</a>，当你击杀一名角色时你可将其技能永久收入【画境】中；<br/>" ..
        "当你获得游戏胜利时，你可以将本局游戏中其他角色的武将技能收入【画境】。你的所有技能不会因画境外的方式失去。<br/>" ..
        "出牌阶段，你可以调整【画境】中的技能。",
    ["#qc__huajing-kill"] = "画境：请选择要收入【画境】的技能",
    ["#qc__huajing-win"] = "画境：请选择要收入【画境】的技能",
    ["#qc__huajing-adjust"] = "画境：请选择要启用的技能",
    ["@qc__huajing-count"] = "画境",
    ["General_Skill"] = "共鸣技，该技能仅限原武将牌上的角色才能发动。",
    ["#qc__huajing-choice-title"] = "画境",
    ["#qc__huajing-choice-prompt"] = "请选择操作模式：",
    ["#qc__huajing-confirm-del"] = "警告：该操作会从存档中永久删除该技能！请谨慎操作。",
}
--获取武将及副将的技能
local function getCleanSkills(player)
    local skills = {}
    local general = Fk.generals[player.general]
    if not general then return skills end
    for _, skillName in ipairs(player:getSkillNameList()) do
        local s = Fk.skills[skillName]
        if s and not s.attached_equip and not skillName:endsWith("&") and not skillName:startsWith("#") and
            not s.cardSkill and s:isPlayerSkill() and skillName ~= "qc__huajing" then
            table.insertIfNeed(skills, skillName)
        end
    end
    if player.deputyGeneral ~= "" then
        local deputy = Fk.generals[player.deputyGeneral]
        if deputy then
            for _, skillName in ipairs(deputy:getSkillNameList()) do
                local s = Fk.skills[skillName]
                if s and not s.attached_equip and not skillName:endsWith("&") and not skillName:startsWith("#") and
                    not s.cardSkill and s:isPlayerSkill() and skillName ~= "qc__huajing" then
                    table.insertIfNeed(skills, skillName)
                end
            end
        end
    end
    return skills
end
--玩家技能选择
local function chooseplayerskill(player, room, prompt)
    prompt = prompt or "#playerskillpo-choose"
    local skills = {}
    for _, s in ipairs(player.player_skills) do
        if not (s.attached_equip or s.name:endsWith("&")) and not s.name:startsWith("#") then
            table.insertIfNeed(skills, s.name)
        end
    end
    local result = room:askToCustomDialog(player, {
        skill_name = "选择",
        qml_path = "packages/utility/qml/ChooseSkillBox.qml",
        extra_data = { skills, 0, #skills, prompt }
    })
    if result ~= "" then
        return result
    end
    return {}
end

--永恒技实现，放置在最上方
qc__huajing:addLoseEffect(function(self, player, is_death)
    local room = player.room
    room:handleAddLoseSkills(player, qc__huajing.name, nil, false, true)
end)

qc__huajing:addAcquireEffect(function(self, player, is_start)
    local gamedata = player:getGlobalSaveState("QC__HUAJING")
    if gamedata and gamedata.skills then
        player.room:setPlayerMark(player, "@qc__huajing-count", #gamedata.skills)
        player.room:handleAddLoseSkills(player, table.concat(gamedata.skills, "|"), nil, false, true)
    end
end)

qc__huajing:addEffect(fk.Death, {
    can_trigger = function(self, event, target, player, data)
        return data.killer == player and player:hasSkill(qc__huajing.name) and player.general == "QC__huayaweiyan"
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local victim = data.who
        local victim_skills = getCleanSkills(victim)
        if #victim_skills == 0 then return end

        local gamedata = player:getGlobalSaveState("QC__HUAJING") or { skills = {} }
        if not gamedata.skills then gamedata.skills = {} end
        local skills_to_show = {}
        for _, s in ipairs(victim_skills) do
            if not table.contains(gamedata.skills, s) then
                table.insert(skills_to_show, s)
            end
        end
        if #skills_to_show == 0 then return end

        local choices = U.askToChooseGeneralSkills(player, {
            generals = { victim.general },
            skills = { skills_to_show },
            min_num = 0,
            max_num = #skills_to_show,
            skill_name = qc__huajing.name,
            prompt = "#qc__huajing-kill",
            cancelable = true,
        })

        if #choices > 0 then
            for _, s in ipairs(choices) do
                table.insertIfNeed(gamedata.skills, s)
            end
            player:saveGlobalState("QC__HUAJING", gamedata)
            room:setPlayerMark(player, "@qc__huajing-count", #gamedata.skills)
            room:handleAddLoseSkills(player, table.concat(choices, "|"), nil, false, true)
        end
    end
})

qc__huajing:addEffect(fk.GameFinished, {
    anim_type = "control",
    is_delay_effect = true,
    mute = true,
    priority = 10000,
    can_trigger = function(self, event, target, player, data)
        if player:hasSkill(qc__huajing.name, false, false) and player.general == "QC__huayaweiyan" then
            local win = data:split("+")
            return table.contains(win, player.role)
        end
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local gamedata = player:getGlobalSaveState("QC__HUAJING") or { skills = {} }
        if not gamedata.skills then gamedata.skills = {} end

        local adjust_choice = room:askToChoice(player, {
            choices = { "调整存档画境", "收入新技能" },
            skill_name = qc__huajing.name,
            prompt = "是否调整你的存档画境？"
        })

        if adjust_choice == "调整存档画境" then
            local confirm = room:askToChoice(player, {
                choices = { "确认删除", "取消" },
                skill_name = qc__huajing.name,
                prompt = "#qc__huajing-confirm-del"
            })
            if confirm == "确认删除" then
                local skills = chooseplayerskill(player, room, "请选择要删除的技能：") or {}
                if table.contains(skills, "qc__huajing") then
                    table.removeOne(skills, "qc__huajing")
                end
                if #skills > 0 then
                    local gamedata_to_del = player:getGlobalSaveState("QC__HUAJING") or { skills = {} }
                    if not gamedata_to_del.skills then gamedata_to_del.skills = {} end
                    local skills_to_delete_from_archive = {}
                    for _, skill_to_delete in ipairs(skills) do
                        if table.contains(gamedata_to_del.skills, skill_to_delete) then
                            table.insert(skills_to_delete_from_archive, skill_to_delete)
                        end
                    end
                    if #skills_to_delete_from_archive > 0 then
                        for _, skill_to_delete in ipairs(skills_to_delete_from_archive) do
                            table.removeOne(gamedata_to_del.skills, skill_to_delete)
                        end
                        player:saveGlobalState("QC__HUAJING", gamedata_to_del)
                        room:setPlayerMark(player, "@qc__huajing-count", #gamedata_to_del.skills)
                    end
                    room:handleAddLoseSkills(player, "-" .. table.concat(skills, "|-"), nil, false, true)
                end
            end
        elseif adjust_choice == "收入新技能" then
            local generals_names = {}
            local skills_list = {}
            local gamedata_to_add = player:getGlobalSaveState("QC__HUAJING") or { skills = {} }
            if not gamedata_to_add.skills then gamedata_to_add.skills = {} end
            for _, p in ipairs(room.players) do
                if p ~= player then
                    local ps = getCleanSkills(p)
                    local ps_filtered = {}
                    for _, s in ipairs(ps) do
                        if not table.contains(gamedata_to_add.skills, s) then
                            table.insert(ps_filtered, s)
                        end
                    end
                    if #ps_filtered > 0 then
                        table.insert(generals_names, p.general)
                        table.insert(skills_list, ps_filtered)
                    end
                end
            end

            if #generals_names > 0 then
                local choices = U.askToChooseGeneralSkills(player, {
                    generals = generals_names,
                    skills = skills_list,
                    min_num = 1,
                    max_num = 100,
                    skill_name = qc__huajing.name,
                    prompt = "#qc__huajing-win",
                    cancelable = false,
                })

                if #choices > 0 then
                    for _, s in ipairs(choices) do
                        table.insertIfNeed(gamedata_to_add.skills, s)
                    end
                    player:saveGlobalState("QC__HUAJING", gamedata_to_add)
                    room:setPlayerMark(player, "@qc__huajing-count", #gamedata_to_add.skills)
                    room:handleAddLoseSkills(player, table.concat(choices, "|"), nil, false, true)
                end
            end
        end
    end
})

qc__huajing:addEffect("active", {
    card_num = 0,
    target_num = 0,
    can_use = function(self, player)
        return player:hasSkill(qc__huajing.name) and player.general == "QC__huayaweiyan"
    end,
    on_use = function(self, room, effect)
        local player = effect.from
        local mode_choices = { "从本局中移除技能", "永久从存档中删除技能" }
        local mode_result = room:askToChoice(player, {
            choices = mode_choices,
            skill_name = qc__huajing.name,
            prompt = "#qc__huajing-choice-prompt"
        })
        if not mode_result then return false end
        local is_permanent_delete = (mode_result == "永久从存档中删除技能")

        if is_permanent_delete then
            local confirm = room:askToChoice(player, {
                choices = { "确认删除", "取消" },
                skill_name = qc__huajing.name,
                prompt = "#qc__huajing-confirm-del"
            })
            if confirm ~= "确认删除" then return false end
        end

        local skills = chooseplayerskill(player, room, "请选择要移除/删除的技能：") or {}
        if table.contains(skills, "qc__huajing") then
            table.removeOne(skills, "qc__huajing")
        end
        if #skills > 0 then
            if not is_permanent_delete then
                room:handleAddLoseSkills(player, "-" .. table.concat(skills, "|-"), nil, false, true)
            else
                local gamedata = player:getGlobalSaveState("QC__HUAJING")
                if gamedata and gamedata.skills then
                    local skills_to_delete_from_archive = {}
                    for _, skill_to_delete in ipairs(skills) do
                        if table.contains(gamedata.skills, skill_to_delete) then
                            table.insert(skills_to_delete_from_archive, skill_to_delete)
                        end
                    end
                    if #skills_to_delete_from_archive > 0 then
                        for _, skill_to_delete in ipairs(skills_to_delete_from_archive) do
                            table.removeOne(gamedata.skills, skill_to_delete)
                        end
                        player:saveGlobalState("QC__HUAJING", gamedata)
                        room:setPlayerMark(player, "@qc__huajing-count", #gamedata.skills)
                    end
                    room:handleAddLoseSkills(player, "-" .. table.concat(skills, "|-"), nil, false, true)
                else
                    room:handleAddLoseSkills(player, "-" .. table.concat(skills, "|-"), nil, false, true)
                end
            end
        end
    end
})

return qc__huajing
