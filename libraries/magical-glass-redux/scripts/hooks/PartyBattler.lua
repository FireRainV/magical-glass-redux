---@class PartyBattler : PartyBattler
local PartyBattler, super = Utils.hookScript(PartyBattler)

function PartyBattler:calculateDamage(amount)
    if Game:isLight() then
        local def = self.chara:getStat("defense")
        local hp = self.chara:getHealth()
        
        local bonus = (MagicalGlassLib.bonus_damage ~= false and self.bonus_damage ~= false) and hp > 20 and math.min(1 + math.floor((hp - 20) / 10), 8) or 0
        amount = Utils.round(amount + bonus - def / 5)
        
        return math.max(amount, 1)
    else
        return super.calculateDamage(self, amount)
    end
end

function PartyBattler:calculateDamageSimple(amount)
    if Game:isLight() then
        return math.ceil(amount - (self.chara:getStat("defense") / 5))
    else
        return super.calculateDamageSimple(self, amount)
    end
end

function PartyBattler:hurt(amount, exact, color, options)
    if type(exact) == "string" then
        exact = false
        self.bonus_damage = false
    end
    super.hurt(self, amount, exact, color, options)
    self.bonus_damage = nil
end

return PartyBattler
