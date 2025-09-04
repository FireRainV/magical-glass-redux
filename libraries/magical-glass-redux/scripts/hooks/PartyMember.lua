---@class PartyMember : PartyMember
local PartyMember, super = Utils.hookScript(PartyMember)

function PartyMember:getLightNoWeaponAnimation()
    return self.light_no_weapon_animation
end

function PartyMember:getDamageColor()
    if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() and #Game.battle.party == 1 then
        return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color_damage_single"])
    elseif self.dmg_color_lw and Game:isLight() then
        return Utils.unpackColor(self.dmg_color_lw)
    else
        return super.getDamageColor(self)
    end
end

function PartyMember:getAttackBarColor()
    if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() then
        return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color_attackbar"])
    elseif self.attack_bar_color_lw and Game:isLight() then
        return Utils.unpackColor(self.attack_bar_color_lw)
    else
        return super.getAttackBarColor(self)
    end
end

function PartyMember:convertToLight()
    local last_weapon = self:getWeapon() and self:getWeapon().id or false
    local last_armors = {self:getArmor(1) and self:getArmor(1).id or false, self:getArmor(2) and self:getArmor(2).id or false}
    
    self.equipped = {weapon = nil, armor = {}}
    
    if self:getFlag("light_weapon") then
        self.equipped.weapon = Registry.createItem(self:getFlag("light_weapon"))
    end
    if self:getFlag("light_armor") then
        self.equipped.armor[1] = Registry.createItem(self:getFlag("light_armor"))
    end
    
    if self:getFlag("light_weapon") == nil then
        self.equipped.weapon = self.lw_weapon_default and Registry.createItem(self.lw_weapon_default) or nil
    end
    if self:getFlag("light_armor") == nil then
        self.equipped.armor[1] = self.lw_armor_default and Registry.createItem(self.lw_armor_default) or nil
    end
    
    if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
        if last_weapon then
            local result = Registry.createItem(last_weapon):convertToLightEquip(self)
            if result then
                if type(result) == "string" then
                    result = Registry.createItem(result)
                end
                if isClass(result) and self:canEquip(result, "weapon", 1) and self.equipped.weapon and self.equipped.weapon.dark_item and self.equipped.weapon.equip_can_convert ~= false then
                    self.equipped.weapon = result
                end
            end
        end
        local converted = false
        for i = 1, 2 do
            if last_armors[i] then
                local result = Registry.createItem(last_armors[i]):convertToLightEquip(self)
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) and self:canEquip(result, "armor", 1) and (self.equipped.armor[1] and (self.equipped.armor[1].equip_can_convert or self.equipped.armor[1].id == result.id) or not self.equipped.armor[1]) then
                        if self:getFlag("converted_light_armor") == nil then
                            if self.equipped.armor[1] and self.equipped.armor[1].id == result.id then
                                self:setFlag("converted_light_armor", "light/bandage")
                            else
                                self:setFlag("converted_light_armor", self.equipped.armor[1] and self.equipped.armor[1].id or "light/bandage")
                            end
                        end
                        converted = true
                        self.equipped.armor[1] = result
                        break
                    end
                end
            end
        end
        if not converted and self:getFlag("converted_light_armor") ~= nil then
            self.equipped.armor[1] = self:getFlag("converted_light_armor") and Registry.createItem(self:getFlag("converted_light_armor")) or nil
            self:setFlag("converted_light_armor", nil)
        end
    end
    
    self:setFlag("dark_weapon", last_weapon)
    self:setFlag("dark_armors", last_armors)
end

function PartyMember:convertToDark()
    local last_weapon = self:getWeapon() and self:getWeapon().id or false
    local last_armor = self:getArmor(1) and self:getArmor(1).id or false
    
    self.equipped = {weapon = nil, armor = {}}
    
    if self:getFlag("dark_weapon") then
        self.equipped.weapon = Registry.createItem(self:getFlag("dark_weapon"))
    end
    for i = 1, 2 do
        if self:getFlag("dark_armors") and self:getFlag("dark_armors")[i] then
            self.equipped.armor[i] = Registry.createItem(self:getFlag("dark_armors")[i])
        end
    end
    
    if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
        if last_weapon then
            local result = Registry.createItem(last_weapon).dark_item
            if result then
                if type(result) == "string" then
                    result = Registry.createItem(result)
                end
                if isClass(result) and self:canEquip(result, "weapon", 1) and self.equipped.weapon and self.equipped.weapon:convertToLightEquip(self) and self.equipped.weapon.equip_can_convert ~= false then
                    self.equipped.weapon = result
                end
            end
        end
        if last_armor then
            local result = Registry.createItem(last_armor).dark_item
            if result then
                if type(result) == "string" then
                    result = Registry.createItem(result)
                end
                if isClass(result) then
                    local slot
                    for i = 1, 2 do
                        if self:canEquip(result, "armor", i) then
                            slot = i
                            break
                        end
                    end
                    if slot then
                        if self:getFlag("converted_light_armor") == nil then
                            self:setFlag("converted_light_armor", "light/bandage")
                        end
                        local already_equipped = false
                        for i = 1, 2 do
                            if self.equipped.armor[i] and (self.equipped.armor[i].id == result.id or self.equipped.armor[i].equip_can_convert == false) then
                                already_equipped = true
                            end
                        end
                        if not already_equipped then
                            for i = 1, 2 do
                                if self.equipped.armor[i] then
                                    Game.inventory:addItem(self.equipped.armor[i].id)
                                end
                                self.equipped.armor[i] = nil
                            end
                            self.equipped.armor[slot] = result
                        end
                    end
                end
            else
                for i = 1, 2 do
                    if self:getFlag("converted_light_armor") ~= nil and self.equipped.armor[i] and self.equipped.armor[i]:convertToLightEquip(self) then
                        self.equipped.armor[i] = nil
                        self:setFlag("converted_light_armor", nil)
                        break
                    end
                end
            end
        end
    end
    
    self:setFlag("light_weapon", last_weapon)
    self:setFlag("light_armor", last_armor)
end

function PartyMember:getUndertaleMovement()
    return self.undertale_movement
end

function PartyMember:onLightTurnStart(battler)
end

function PartyMember:onLightTurnEnd(battler)
    for _,equip in ipairs(self:getEquipment()) do
        if equip.onLightTurnEnd then
            equip:onLightTurnEnd(battler)
        end
    end
end

function PartyMember:onLightLevelUp()
    if self:getLightLV() < #self.lw_exp_needed or self:getLightEXPNeeded(#self.lw_exp_needed) >= self.lw_exp then
        local old_lv = self:getLightLV()
        local new_lv = 1
        for lv, exp in pairs(self.lw_exp_needed) do
            if self:getLightEXP() >= exp then
                new_lv = lv
            end
        end
        if old_lv < 1 and self:getLightEXP() < self.lw_exp_needed[1] then
            new_lv = old_lv
        end
        if old_lv ~= new_lv and new_lv <= #self.lw_exp_needed then
            self:setLightLV(new_lv, false)
        end
    end
end

function PartyMember:setLightLV(level, force_exp)
    self.lw_lv = level
    if force_exp ~= false then
        if self.lw_lv > #self.lw_exp_needed then
            self.lw_exp = self.lw_exp_needed[#self.lw_exp_needed] + 1
        elseif self.lw_exp_needed[level] then
            self.lw_exp = self:getLightEXPNeeded(level)
        else
            self.lw_exp = 0
        end
    end
    
    self.lw_stats = self:lightLVStats()
    for stat,amount in pairs(self.lw_stats_bonus) do
        self.lw_stats[stat] = self.lw_stats[stat] + amount
    end
end

function PartyMember:setLightEXP(exp)
    self.lw_exp = exp
    self:onLightLevelUp()
end

function PartyMember:getShortName()
    return self.short_name or Utils.sub(self:getName(), 1, 6)
end

function PartyMember:getLightStatText()
    return self.lw_stat_text 
end

function PartyMember:getLightAttackColor()
    if Game.battle and not Game.battle.multi_mode then
        return Utils.unpackColor({1, 105/255, 105/255})
    elseif self.light_attack_color_dw and not Game:isLight() then
        return Utils.unpackColor(self.light_attack_color_dw)
    elseif self.light_attack_color and Game:isLight() then
        return Utils.unpackColor(self.light_attack_color)
    else
        return self:getColor()
    end
end

function PartyMember:getLightDamageColor()
    if Game.battle and not Game.battle.multi_mode then
        return Utils.unpackColor(COLORS.red)
    elseif self.light_dmg_color_dw and not Game:isLight() then
        return Utils.unpackColor(self.light_dmg_color_dw)
    elseif self.light_dmg_color and Game:isLight() then
        return Utils.unpackColor(self.light_dmg_color)
    else
        return self:getColor()
    end
end

function PartyMember:getLightMissColor()
    if Game.battle and not Game.battle.multi_mode then
        return Utils.unpackColor(COLORS.silver)
    elseif self.light_miss_color_dw and not Game:isLight() then
        return Utils.unpackColor(self.light_miss_color_dw)
    elseif self.light_miss_color and Game:isLight() then
        return Utils.unpackColor(self.light_miss_color)
    else
        return self:getColor()
    end
end

function PartyMember:onLightAttackHit(enemy, damage)
end

function PartyMember:getLightAttackBarColor()
    if Game.battle and not Game.battle.multi_mode then
        return Utils.unpackColor(COLORS.white)
    elseif self.light_attack_bar_color_dw and not Game:isLight() then
        return Utils.unpackColor(self.light_attack_bar_color_dw)
    elseif self.light_attack_bar_color and Game:isLight() then
        return Utils.unpackColor(self.light_attack_bar_color)
    else
        return self:getColor()
    end
end

function PartyMember:getLightXActColor()
    if self.light_xact_color_dw and not Game:isLight() then
        return Utils.unpackColor(self.light_xact_color_dw)
    elseif self.light_xact_color and Game:isLight() then
        return Utils.unpackColor(self.light_xact_color)
    else
        return self:getXActColor()
    end
end

function PartyMember:getNameOrYou(lower)
    if Game.party[1] and self.id == Game.party[1].id and not (not Kristal.getLibConfig("magical-glass", "multi_leader_mentioned_as_you") and (Game.battle and Game.battle.multi_mode or not Game.battle and #Game.party > 1)) then
        if lower then
            return "you", true
        else
            return "You", true
        end
    else
        return self:getName(), false
    end
end

function PartyMember:onSave(data)
    super.onSave(self, data)
    data.lw_stat_text = self.lw_stat_text
    data.lw_portrait = self.lw_portrait
    data.lw_stats_bonus = self.lw_stats_bonus
end

function PartyMember:onLoad(data)
    super.onLoad(self, data)
    self.lw_stat_text = data.lw_stat_text or self.lw_stat_text
    self.lw_portrait = data.lw_portrait or self.lw_portrait
    self.lw_stats_bonus = data.lw_stats_bonus or self.lw_stats_bonus
end

function PartyMember:addLightEXP(exp)
    if self:getLightEXP() >= self.lw_exp_needed[1] and self:getLightEXP() <= self.lw_exp_needed[#self.lw_exp_needed] then
        self:setLightEXP(Utils.clamp(self:getLightEXP() + exp, self.lw_exp_needed[1], self.lw_exp_needed[#self.lw_exp_needed]))
    else
        self:setLightEXP(self:getLightEXP() + exp)
    end
end

function PartyMember:onTurnEnd(battler)
    for _,equip in ipairs(self:getEquipment()) do
        if equip.onTurnEnd then
            equip:onTurnEnd(battler)
        end
    end
end

function PartyMember:init()
    super.init(self)
    
    self.short_name = nil
    
    self.undertale_movement = false
    
    self.light_no_weapon_animation = "custom/ring"
    
    self.lw_stats_bonus = {
        health = 0,
        attack = 0,
        defense = 0,
        magic = 0
    }
    -- Light Stat Menu stuff
    self.lw_stat_text = nil
    self.lw_portrait = nil
    -- Main Color
    self.light_color = nil
    
    -- Light Battle Colors
    self.light_dmg_color = nil
    self.light_miss_color = nil
    self.light_attack_color = nil
    self.light_multibolt_attack_color = nil
    self.light_attack_bar_color = nil
    self.light_xact_color = nil
    
    -- Light Battle Colors in the dark world
    self.light_dmg_color_dw = nil
    self.light_miss_color_dw = nil
    self.light_attack_color_dw = nil
    self.light_multibolt_attack_dw = nil
    self.light_attack_bar_color_dw = nil
    self.light_xact_color_dw = nil
    
    -- Dark Battle Colors in the light world
    self.dmg_color_lw = nil
    self.attack_bar_color_lw = nil
    self.attack_box_color_lw = nil
    self.xact_color_lw = nil
    self.lw_stats["magic"] = 0
    
    if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
        Game.stage.timer:after(1/30, function()
            if not Game:isLight() and MagicalGlassLib.initialize_armor_conversion then
                for i = 1, 2 do
                    if self.equipped.armor[i] and self.equipped.armor[i]:convertToLightEquip(self) == self.lw_armor_default then
                        self:setFlag("converted_light_armor", "light/bandage")
                        break
                    end
                end
            end
        end)
    end
end

function PartyMember:getLightMultiboltAttackColor()
    if Game.battle and not Game.battle.multi_mode then
        return Utils.unpackColor(COLORS.white)
    elseif self.light_multibolt_attack_color_dw and not Game:isLight() then
        return Utils.unpackColor(self.light_multibolt_attack_color_dw)
    elseif self.light_multibolt_attack_color and Game:isLight() then
        return Utils.unpackColor(self.light_multibolt_attack_color)
    else
        return self:getColor()
    end
end

function PartyMember:getLightPortrait()
    return self.lw_portrait 
end

function PartyMember:increaseStat(stat, amount, max)
    if Game:isLight() and amount == "reset" then
        self.lw_stats_bonus[stat] = 0
        self:reloadLightStats()
        return
    end
    local pre_bonus = self:getBaseStats()[stat]
    super.increaseStat(self, stat, amount, max)
    local post_bonus = self:getBaseStats()[stat]
    if Game:isLight() then
        self.lw_stats_bonus[stat] = self.lw_stats_bonus[stat] + post_bonus - pre_bonus
    end
end

function PartyMember:lightLVStats()
    return {
        health = self:getLightLV() == 20 and 99 or 16 + self:getLightLV() * 4,
        attack = 8 + self:getLightLV() * 2,
        defense = 9 + math.ceil(self:getLightLV() / 4),
        magic = 0
    }
end

function PartyMember:onLightActionSelect(battler, undo)
end

function PartyMember:getColor()
    if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() and Game.battle and not Game.battle.light then
        return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color"])
    elseif self.light_color and Game:isLight() then
        return Utils.unpackColor(self.light_color)
    else
        return super.getColor(self)
    end
end

function PartyMember:getAttackBoxColor()
    if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() then
        return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color_attackbox"])
    elseif self.attack_box_color_lw and Game:isLight() then
        return Utils.unpackColor(self.attack_box_color_lw)
    else
        return super.getAttackBoxColor(self)
    end
end

function PartyMember:getXActColor()
    if self.xact_color_lw and Game:isLight() then
        return Utils.unpackColor(self.xact_color_lw)
    else
        return super.getXActColor(self)
    end
end

function PartyMember:reloadLightStats()
    self:setLightLV(self:getLightLV(), false)
end

return PartyMember
