local item, super = Class(LightEquipItem, "undertale/bandage")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Bandage"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 150
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "It has already been used several times."

    -- Light world check text
    self.check = "Heals 10 HP\n* It has already been used\nseveral times."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Amount this item heals
    self.heal_amount = 10

    -- Amount this item heals for in the overworld (optional)
    self.world_heal_amount = nil
    -- Amount this item heals for in battle (optional)
    self.battle_heal_amount = nil

    -- Amount this item heals for specific characters
    self.heal_amounts = {}

    -- Amount this item heals for specific characters in the overworld (optional)
    self.world_heal_amounts = {}
    -- Amount this item heals for specific characters in battle (optional)
    self.battle_heal_amounts = {}
    
    -- Whether this equipment item can convert on light change
    self.equip_can_convert = true
    
    -- Flee bonus
    self.flee_bonus = 100
end

function item:onWorldUse(target)
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

    Assets.playSound("power")
    if target.id == Game.party[1].id then
        if not MagicalGlassLib.serious_mode then
            Game.world:heal(target, amount, "* You re-applied the bandage.\n* Still kind of gooey.", self)
        else
            Game.world:heal(target, amount, "* You re-applied the bandage.", self)
        end
    else
        Game.world:heal(target, amount, "* " .. target:getName() .. " applied the bandage.", self)
    end
    return true
end

function item:getLightBattleText(user, target)
    if target.chara.id == Game.battle.party[1].chara.id then
        if not MagicalGlassLib.serious_mode then
            return "* You re-applied the bandage.\n* Still kind of gooey."
        else
            return "* You re-applied the bandage."
        end
    else
        return "* "..target.chara:getName().." applied the bandage."
    end
end

function item:getBattleText(user, target)
    return "* ".. user.chara:getName() .. " used the " .. self:getUseName() .. "!"
end

function item:onLightBattleUse(user, target)
    Assets.stopAndPlaySound("power")
    local amount = self:getBattleHealAmount(target.chara.id)
    for _,equip in ipairs(user.chara:getEquipment()) do
        if equip.getHealBonus then
            amount = amount + equip:getHealBonus()
        end
    end
    target:heal(amount)
    Game.battle:battleText(self:getLightBattleText(user, target).."\n"..self:getLightBattleHealingText(user, target, amount))
end

function item:onBattleUse(user, target)
    local amount = self:getBattleHealAmount(target.chara.id)
    for _,equip in ipairs(user.chara:getEquipment()) do
        if equip.getHealBonus then
            amount = amount + equip:getHealBonus()
        end
    end
    target:heal(amount)
end

function item:getLightBattleHealingText(user, target, amount)
    if target then
        if self.target == "ally" then
            maxed = target.chara:getHealth() >= target.chara:getStat("health")
        elseif self.target == "enemy" then
            maxed = target.health >= target.max_health
        end
    end

    local message
    if self.target == "ally" then
        if target.chara.id == Game.battle.party[1].chara.id and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
        else
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
        end
    end
    return message
end

function item:getLightWorldHealingText(target, amount, maxed)
    if target then
        if self.target == "ally" then
            maxed = target:getHealth() >= target:getStat("health")
        end
    end

    local message
    if target.id == Game.party[1].id and maxed then
        message = "* Your HP was maxed out."
    elseif maxed then
        message = "* " .. target:getName() .. "'s HP was maxed out."
    else
        message = "* " .. target:getNameOrYou() .. " recovered " .. amount .. " HP."
    end
    return message
end

function item:getHealAmount(id)
    return self.heal_amounts[id] or self.heal_amount
end

function item:getWorldHealAmount(id)
    return self.world_heal_amounts[id] or self.world_heal_amount or self:getHealAmount(id)
end

function item:getBattleHealAmount(id)
    return self.battle_heal_amounts[id] or self.battle_heal_amount or self:getHealAmount(id)
end

return item