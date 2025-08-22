---@class Spell : Spell
local Spell, super = Utils.hookScript(Spell)

function Spell:getLightWorldCastMessage(user, target)
    return "* "..user:getNameOrYou().." cast "..self:getName().."."..(Utils.containsValue(self.tags, "heal") and self:getWorldHealMessage(user, target, MagicalGlassLib.heal_amount) and "\n"..self:getWorldHealMessage(user, target, MagicalGlassLib.heal_amount) or "")
end

function Spell:getWorldHealMessage(user, target, amount)
    local maxed = false
    if self.target == "ally" then
        maxed = target:getHealth() >= target:getStat("health") or amount == math.huge
    elseif self.target == "party" and #Game.party == 1 then
        maxed = target[1]:getHealth() >= target[1]:getStat("health") or amount == math.huge
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

function Spell:onLightWorldStart(user, target)
    MagicalGlassLib.heal_amount = nil
    self:onLightWorldCast(target)
    Game.world:showText(self:getLightWorldCastMessage(user, target))
end

function Spell:init()
    super.init(self)
    
    self.check = "Example info"
end

function Spell:onCheck()
    if type(self:getCheck()) == "table" then
        local text
        for i, check in ipairs(self:getCheck()) do
            if i > 1 then
                if text == nil then
                    text = {}
                end
                table.insert(text, check)
            end
        end
        Game.world:showText({{"* \""..self:getName().."\" - "..(self:getCheck()[1] or "")}, text})
    else
        Game.world:showText("* \""..self:getName().."\" - "..self:getCheck())
    end
end

function Spell:getCheck()
    return self.check
end

function Spell:onLightStart(user, target)
    MagicalGlassLib.heal_amount = nil
    if Utils.containsValue(self.tags, "damage") then
        if isClass(target) then
            if target:includes(LightEnemyBattler) and target.immune_to_damage then
                target:onDodge(user, true)
            end
        elseif type(target) == "table" then
            for _,enemy in ipairs(target) do
                if enemy:includes(LightEnemyBattler) and enemy.immune_to_damage then
                    enemy:onDodge(user, true)
                end
            end
        end
    end
    local result = self:onLightCast(user, target)
    Game.battle:battleText(self:getLightCastMessage(user, target))
    if result or result == nil then
        Game.battle:finishActionBy(user)
    end
end

function Spell:onLightCast(user, target)
    return self:onCast(user, target)
end

function Spell:getLightCastMessage(user, target)
    return "* "..user.chara:getNameOrYou().." cast "..self:getName().."."..(Utils.containsValue(self.tags, "heal") and self:getHealMessage(user, target, MagicalGlassLib.heal_amount) and "\n"..self:getHealMessage(user, target, MagicalGlassLib.heal_amount) or "")
end

function Spell:getHealMessage(user, target, amount)
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

function Spell:onLightWorldCast(target)
    self:onWorldCast(target)
end

return Spell
