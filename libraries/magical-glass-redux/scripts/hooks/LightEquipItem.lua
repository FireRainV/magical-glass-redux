---@class LightEquipItem : LightEquipItem
local LightEquipItem, super = Utils.hookScript(LightEquipItem)

function LightEquipItem:onWorldUse(target)
    local chara = target
    local replacing = nil
    if self.type == "weapon" then
        replacing = chara:getWeapon()
    elseif self.type == "armor" then
        replacing = chara:getArmor(1)
    end
    
    if self:onManualEquip(chara, replacing) then
        Assets.playSound("item")
        if replacing then
            Game.inventory:replaceItem(self, replacing)
        end
        if self.type == "weapon" then
            chara:setWeapon(self)
        elseif self.type == "armor" then
            chara:setArmor(1, self)
        else
            error("LightEquipItem "..self.id.." invalid type: "..self.type)
        end
        
        self:showEquipText(target)
        return replacing == nil
    else
        self:showEquipTextFail(target)
        return false
    end
end

function LightEquipItem:onManualEquip(target, replacement)
    local can_equip = true
    if (not self:onEquip(target, replacement)) then can_equip = false end
    if replacement and (not replacement:onUnequip(target, self)) then can_equip = false end
    if (not target:onEquip(self, replacement)) then can_equip = false end
    if (not target:onUnequip(replacement, self)) then can_equip = false end
    if (not self:canEquip(target, self.type, 1)) then can_equip = false end
    
    -- If one of the functions returned false, the equipping will fail
    return can_equip
end

function LightEquipItem:onBattleSelect(user, target)
    self.storage, self.index = Game.inventory:getItemIndex(self)
    return true
end

function LightEquipItem:getBattleText(user, target)
    local replacing = nil
    if self.type == "weapon" then
        replacing = target.chara:getWeapon()
    elseif self.type == "armor" then
        replacing = target.chara:getArmor(1)
    end
    
    if self:onManualEquip(target.chara, replacing) then
        local text = "* "..target.chara:getName().." equipped the "..self:getUseName().."!"
        if user ~= target then
            text = "* "..user.chara:getName().." gave the "..self:getUseName().." to "..target.chara:getName().."!\n" .. "* "..target.chara:getName().." equipped it!"
        end
        return text
    else
        local text = "* "..target.chara:getName().." didn't want to equip the "..self:getUseName().."."
        if user ~= target then
            text = "* "..user.chara:getName().." gave the "..self:getUseName().." to "..target.chara:getName().."!\n" .. "* "..target.chara:getName().." didn't want to equip it."
        end
        return text
    end
end

function LightEquipItem:showEquipTextFail(target)
    Game.world:showText("* " .. target:getNameOrYou() .. " didn't want to equip the " .. self:getName() .. ".")
end

function LightEquipItem:convertToDark(inventory)
    return false 
end

function LightEquipItem:getLightBattleText(user, target)
    local text = "* "..target.chara:getNameOrYou().." equipped the "..self:getUseName().."."
    if user ~= target then
        text = "* "..user.chara:getNameOrYou().." gave the "..self:getUseName().." to "..target.chara:getNameOrYou(true)..".\n" .. "* "..target.chara:getNameOrYou().." equipped it."
    end
    return text
end

function LightEquipItem:onBattleUse(user, target)
    local chara = target.chara
    local replacing = nil
    if self.type == "weapon" then
        replacing = chara:getWeapon()
    elseif self.type == "armor" then
        replacing = chara:getArmor(1)
    end
    if self:onManualEquip(chara, replacing) then
        Assets.playSound("item")
        if replacing then
            Game.inventory:addItemTo(self.storage, self.index, replacing)
        end
        if self.type == "weapon" then
            chara:setWeapon(self)
        elseif self.type == "armor" then
            chara:setArmor(1, self)
        else
            error("LightEquipItem "..self.id.." invalid type: "..self.type)
        end
    else
        Game.inventory:addItemTo(self.storage, self.index, self)
    end
    self.storage, self.index = nil, nil
end

function LightEquipItem:getLightBattleTextFail(user, target)
    local text = "* "..target.chara:getNameOrYou().." didn't want to equip the "..self:getUseName().."."
    if user ~= target then
        text = "* "..user.chara:getNameOrYou().." gave the "..self:getUseName().." to "..target.chara:getNameOrYou(true)..".\n" .. "* "..target.chara:getNameOrYou().." didn't want to equip it."
    end
    return text
end

function LightEquipItem:onLightBattleUse(user, target)
    local chara = target.chara
    local replacing = nil
    if self.type == "weapon" then
        replacing = chara:getWeapon()
    elseif self.type == "armor" then
        replacing = chara:getArmor(1)
    end
    if self:onManualEquip(chara, replacing) then
        Assets.playSound("item")
        if replacing then
            Game.inventory:addItemTo(self.storage, self.index, replacing)
        end
        if self.type == "weapon" then
            chara:setWeapon(self)
        elseif self.type == "armor" then
            chara:setArmor(1, self)
        else
            error("LightEquipItem "..self.id.." invalid type: "..self.type)
        end
        
        Game.battle:battleText(self:getLightBattleText(user, target))
    else
        Game.inventory:addItemTo(self.storage, self.index, self)
        Game.battle:battleText(self:getLightBattleTextFail(user, target))
    end
    self.storage, self.index = nil, nil
end

function LightEquipItem:init()
    super.init(self)
    
    self.storage, self.index = nil, nil
    self.target = "ally"
end

function LightEquipItem:showEquipText(target)
    Game.world:showText("* " .. target:getNameOrYou() .. " equipped the " .. self:getName() .. ".")
end

return LightEquipItem
