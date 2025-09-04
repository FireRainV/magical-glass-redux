---@class HealItem : HealItem
local HealItem, super = Utils.hookScript(HealItem)

function HealItem:onWorldUse(target)
    if Game:isLight() then
        local text = self:getWorldUseText(target)
        if self.target == "ally" then
            self:worldUseSound(target)
            local amount = self:getWorldHealAmount(target.id)
            local best_amount
            for _,member in ipairs(Game.party) do
                local equip_amount = 0
                for _,equip in ipairs(member:getEquipment()) do
                    if equip.getHealBonus then
                        equip_amount = equip_amount + equip:getHealBonus()
                    end
                end
                if not best_amount or equip_amount > best_amount then
                    best_amount = equip_amount
                end
            end
            amount = amount + best_amount
            Game.world:heal(target, amount, text, self)
            return true
        elseif self.target == "party" then
            self:worldUseSound(target)
            for _,party_member in ipairs(target) do
                local amount = self:getWorldHealAmount(party_member.id)
                local best_amount
                for _,member in ipairs(Game.party) do
                    local equip_amount = 0
                    for _,equip in ipairs(member:getEquipment()) do
                        if equip.getHealBonus then
                            equip_amount = equip_amount + equip:getHealBonus()
                        end
                    end
                    if not best_amount or equip_amount > best_amount then
                        best_amount = equip_amount
                    end
                end
                amount = amount + best_amount
                Game.world:heal(party_member, amount, text, self)
            end
            return true
        else
            return false
        end
    else
        return super.onWorldUse(self, target)
    end
end

function HealItem:onBattleUse(user, target)
    if Game:isLight() then
        if self.target == "ally" then
            -- Heal single party member
            local amount = self:getBattleHealAmount(target.chara.id)
            for _,equip in ipairs(user.chara:getEquipment()) do
                if equip.getHealBonus then
                    amount = amount + equip:getHealBonus()
                end
            end
            target:heal(amount)
        elseif self.target == "party" then
            -- Heal all party members
            for _,battler in ipairs(target) do
                local amount = self:getBattleHealAmount(battler.chara.id)
                for _,equip in ipairs(user.chara:getEquipment()) do
                    if equip.getHealBonus then
                        amount = amount + equip:getHealBonus()
                    end
                end
                battler:heal(amount)
            end
        elseif self.target == "enemy" then
            -- Heal single enemy (why)
            local amount = self:getBattleHealAmount(target.id)
            for _,equip in ipairs(user.chara:getEquipment()) do
                if equip.getHealBonus then
                    amount = amount + equip:getHealBonus()
                end
            end
            target:heal(amount)
        elseif self.target == "enemies" then
            -- Heal all enemies (why????)
            for _,enemy in ipairs(target) do
                local amount = self:getBattleHealAmount(enemy.id)
                for _,equip in ipairs(user.chara:getEquipment()) do
                    if equip.getHealBonus then
                        amount = amount + equip:getHealBonus()
                    end
                end
                enemy:heal(amount)
            end
        else
            -- No target, do nothing
        end
    else
        super.onBattleUse(self, user, target)
    end
end

function HealItem:getLightBattleHealingText(user, target, amount)
    local maxed = false
    if self.target == "ally" then
        maxed = target.chara:getHealth() >= target.chara:getStat("health") or amount == math.huge
    elseif self.target == "enemy" then
        maxed = target.health >= target.max_health or amount == math.huge
    elseif self.target == "party" and #Game.battle.party == 1 then
        maxed = target[1].chara:getHealth() >= target[1].chara:getStat("health") or amount == math.huge
    end
    local message = ""
    if self.target == "ally" then
        if select(2, target.chara:getNameOrYou()) and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
        else
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "party" then
        if #Game.battle.party > 1 then
            message = "* Everyone recovered " .. amount .. " HP."
        elseif maxed then
            message = "* Your HP was maxed out."
        else
            message = "* You recovered " .. amount .. " HP."
        end
    elseif self.target == "enemy" then
        if maxed then
            message = "* " .. target.name .. "'s HP was maxed out."
        else
            message = "* " .. target.name .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "enemies" then
        message = "* The enemies recovered " .. amount .. " HP."
    end
    return message
end

function HealItem:getLightBattleText(user, target)
    if self.target == "ally" then
        return "* " .. target.chara:getNameOrYou() .. " "..self:getUseMethod(target.chara).." the " .. self:getUseName() .. "."
    elseif self.target == "party" then
        if #Game.battle.party > 1 then
            return "* Everyone "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
        else
            return "* You "..self:getUseMethod("self").." the " .. self:getUseName() .. "."
        end
    elseif self.target == "enemy" then
        return "* " .. target.name .. " "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
    elseif self.target == "enemies" then
        return "* The enemies "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
    end
end

function HealItem:battleUseSound(user, target)
    Game.battle.timer:script(function(wait)
        Assets.stopAndPlaySound("swallow")
        wait(0.4)
        Assets.stopAndPlaySound("power")
    end)
end

function HealItem:worldUseSound(target)
    Game.world.timer:script(function(wait)
        Assets.stopAndPlaySound("swallow")
        wait(0.4)
        Assets.stopAndPlaySound("power")
    end)
end

function HealItem:onLightBattleUse(user, target)
    local text = self:getLightBattleText(user, target)
    if self.target == "ally" then
        self:battleUseSound(user, target)
        local amount = self:getBattleHealAmount(target.chara.id)
        for _,equip in ipairs(user.chara:getEquipment()) do
            if equip.getHealBonus then
                amount = amount + equip:getHealBonus()
            end
        end
        target:heal(amount, false)
        if self:getLightBattleHealingText(user, target, amount) then
            if type(text) == "table" then
                text[#text] = text[#text] .. (text[#text] ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            else
                text = text .. (text ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            end
        end
        Game.battle:battleText(text)
        return true
    elseif self.target == "party" then
        self:battleUseSound(user, target)
        local amount = 0
        for _,battler in ipairs(target) do
            amount = self:getBattleHealAmount(battler.chara.id)
            for _,equip in ipairs(user.chara:getEquipment()) do
                if equip.getHealBonus then
                    amount = amount + equip:getHealBonus()
                end
            end
            battler:heal(amount, false)
        end
        if self:getLightBattleHealingText(user, target, amount) then
            if type(text) == "table" then
                text[#text] = text[#text] .. (text[#text] ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            else
                text = text .. (text ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            end
        end
        Game.battle:battleText(text)
        return true
    elseif self.target == "enemy" then
        local amount = self:getBattleHealAmount(target.id)
        
        for _,equip in ipairs(user.chara:getEquipment()) do
            if equip.getHealBonus then
                amount = amount + equip:getHealBonus()
            end
        end
        target:heal(amount)
        
        if self:getLightBattleHealingText(user, target, amount) then
            if type(text) == "table" then
                text[#text] = text[#text] .. (text[#text] ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            else
                text = text .. (text ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            end
        end
        Game.battle:battleText(text)
        return true
    elseif self.target == "enemies" then
        local amount = 0
        for _,enemy in ipairs(target) do
            amount = self:getBattleHealAmount(enemy.id)
            for _,equip in ipairs(user.chara:getEquipment()) do
                if equip.getHealBonus then
                    amount = amount + equip:getHealBonus()
                end
            end
            
            enemy:heal(amount)
        end
        
        if self:getLightBattleHealingText(user, target, amount) then
            if type(text) == "table" then
                text[#text] = text[#text] .. (text[#text] ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            else
                text = text .. (text ~= "" and "\n" or "") .. self:getLightBattleHealingText(user, target, amount)
            end
        end
        Game.battle:battleText(text)
        return true
    else
        -- No target or enemy target (?), do nothing
        return false
    end
end

function HealItem:getWorldUseText(target)
    if self.target == "ally" then
        return "* " .. target:getNameOrYou() .. " "..self:getUseMethod(target).." the " .. self:getUseName() .. "."
    elseif self.target == "party" then
        if #Game.party > 1 then
            return "* Everyone "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
        else
            return "* You "..self:getUseMethod("self").." the " .. self:getUseName() .. "."
        end
    end
end

function HealItem:getLightWorldHealingText(target, amount)
    local maxed = false
    if self.target == "ally" or self.target == "party" and #Game.party == 1 then
        maxed = target:getHealth() >= target:getStat("health") or amount == math.huge
    end
    local message = ""
    if self.target == "ally" then
        if select(2, target:getNameOrYou()) and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target:getNameOrYou() .. "'s HP was maxed out."
        else
            message = "* " .. target:getNameOrYou() .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "party" then
        if #Game.party > 1 then
            message = "* Everyone recovered " .. amount .. " HP."
        elseif maxed then
            message = "* Your HP was maxed out."
        else
            message = "* You recovered " .. amount .. " HP."
        end
    end
    return message
end

return HealItem
