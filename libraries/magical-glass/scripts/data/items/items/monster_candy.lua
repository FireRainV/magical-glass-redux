local item, super = Class(HealItem, "items/monster_candy")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Monster Candy"
    self.short_name = "MnstrCndy"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 10

    -- Default shop price (sell price is halved)
    self.price = 25
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Heals 10 HP\n* Has a distinct,[wait:2]\nnon licorice flavor."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
    
    -- Default dark item conversion for this item
    self.dark_item = "dark_candy"
end

function item:getLightBattleText(target)
    local message = ""
    if not Game:getFlag("#serious_mode") then
        local picker = Utils.random(0, 15, 1)
        if picker == 15 then
            message = "\n* ... tastes like licorice."
        end

        if picker <= 2 then
            message = "\n* Very un-licorice-like."
        end
    end

    return "* " .. target.chara:getNameOrYou() .. " ate the Monster Candy."..message
end

return item