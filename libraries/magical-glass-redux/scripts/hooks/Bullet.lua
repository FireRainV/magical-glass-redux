---@class Bullet : Bullet
local Bullet, super = Utils.hookScript(Bullet)

function Bullet:getDamage()
    if Game:isLight() then
        return self.damage or (self.attacker and self.attacker.attack) or 0
    else
        return super.getDamage(self)
    end
end

function Bullet:onDamage(soul)
    MagicalGlassLib.bonus_damage = nil
    if self.attacker then
        MagicalGlassLib.bonus_damage = self.attacker.bonus_damage
    end
    if self.bonus_damage ~= nil then
        MagicalGlassLib.bonus_damage = self.bonus_damage
    end
    local battlers = super.onDamage(self, soul)
    MagicalGlassLib.bonus_damage = nil
    
    if self:getDamage() > 0 then
        local best_amount
        for _,battler in ipairs(battlers) do
            local equip_amount = 0
            for _,equip in ipairs(battler.chara:getEquipment()) do
                if equip.getInvBonus then
                    equip_amount = equip_amount + equip:getInvBonus()
                end
            end
            if not best_amount or equip_amount > best_amount then
                best_amount = equip_amount
            end
        end
        soul.inv_timer = soul.inv_timer + (best_amount or 0)
    end
    
    return battlers
end

function Bullet:onCollide(soul)
    if soul.inv_timer == 0 then
        self:onDamage(soul)
        if self.destroy_on_hit then
            self:remove()
        end
    elseif self.destroy_on_hit == true then
        self:remove()
    end
end

function Bullet:init(x, y, texture)
    super.init(self, x, y, texture)
    if Game:isLight() then
        self.inv_timer = 1
    end
    if Game.battle.light then
        self.destroy_on_hit = "alt"
        self.layer = LIGHT_BATTLE_LAYERS["bullets"]
    end
    self.bonus_damage = nil -- Whether the bullet deals bonus damage when having more HP (Light World only)
    self.remove_outside_of_arena = false
end

function Bullet:update()
    super.update(self)
    local x, y = self:getScreenPos()
    if self.remove_outside_of_arena and
        (x < Game.battle.arena.left or
        x > Game.battle.arena.right or
        y > Game.battle.arena.bottom or
        y < Game.battle.arena.top)
        then
        self:remove()
    end
end

return Bullet
