local item, super = Class(HealItem, "test/dumb_bun")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Dumb Bun"
    self.short_name = "DumbBun"
    self.serious_name = "D. Bun"
    self.use_name = "Dumb Bunny"

    -- How this item is used on you (ate, drank, eat, etc.)
    self.use_method = "eat"
    -- How this item is used on other party members (eats, etc.)
    self.use_method_other = "eats"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 22

    -- Default shop price (sell price is halved)
    self.price = 25
    -- Default shop sell price
    self.sell_price = 8
    -- Whether the item can be sold
    self.can_sell = true

    -- Item description text (unused by light items outside of debug menu)
    self.description = "A cinnamon roll in the shape of a bunny.\nHeals the enemy."

    -- Light world check text
    self.check = "Heals Enemy 22 HP\n* A cinnamon roll in the shape\nof a bunny."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "enemy"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
    
end

return item