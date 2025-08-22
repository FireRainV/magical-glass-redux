---@class EnemyBattler : EnemyBattler
local EnemyBattler, super = Utils.hookScript(EnemyBattler)

function EnemyBattler:freeze()
    if Game:isLight() then
        Game.battle.money = Game.battle.money - 24 + 2
    end
    super.freeze(self)
end

function EnemyBattler:defeat(reason, violent)
    super.defeat(self, reason, violent)
    if violent then
        if Game:isLight() and (self.done_state == "KILLED" or self.done_state == "FROZEN") then
            MagicalGlassLib.kills = MagicalGlassLib.kills + 1
        end
        if MagicalGlassLib.random_encounter and MagicalGlassLib:createRandomEncounter(MagicalGlassLib.random_encounter).population then
            MagicalGlassLib:createRandomEncounter(MagicalGlassLib.random_encounter):addFlag("violent", 1)
        end
    else
        Game.battle.xp = Game.battle.xp - self.experience
    end
end

function EnemyBattler:init(actor, use_overlay)
    super.init(self, actor, use_overlay)
    
    -- Whether the enemy deals bonus damage when having more HP (Light World only)
    self.bonus_damage = true
end

function EnemyBattler:getAttackDamage(damage, battler, points)
    if damage > 0 then
        return damage
    end
    if Game:isLight() then
        return ((battler.chara:getStat("attack") * points) / 68) - (self.defense * 2.2)
    else
        return super.getAttackDamage(self, damage, battler, points)
    end
end

return EnemyBattler
