---@class Item : Item
local Item, super = Utils.hookScript(Item)

function Item:onLightBoltHit(battler)
end

function Item:getUseMethod(target)
    if type(target) == "string" then
        if target == "other" and self.use_method_other then
            return self.use_method_other
        elseif target == "self" and self.use_method_self then
            return self.use_method
        else
            return self.use_method
        end
    elseif isClass(target) then
        if (not select(2, target:getNameOrYou()) or target.id ~= Game.party[1].id) and self.use_method_other and self.target ~= "party" then
            return self.use_method_other
        else
            return self.use_method
        end
    end
end

function Item:getName()
    if self.light and Game.state == "BATTLE" and not Game.battle.light and self.dark_name then
        return self.dark_name
    else
        return super.getName(self)
    end
end

function Item:getLightBattleHealingText(user, target, amount)
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

function Item:getLightShopDescription()
    return self.shop
end

function Item:getLightShopShowMagic()
    return self.shop_magic
end

function Item:getLightShopDontShowChange()
    return self.shop_dont_show_change
end

function Item:getLightTypeName()
    if self.type == "weapon" then
        if self:getLightShopShowMagic() then
            return "Weapon: " .. self:getStatBonus("magic") .. "MG"
        else
            return "Weapon: " .. self:getStatBonus("attack") .. "AT"
        end
    elseif self.type == "armor" then
        if self:getLightShopShowMagic() then
            return "Armor: " .. self:getStatBonus("magic") .. "MG"
        else
            return "Armor: " .. self:getStatBonus("defense") .. "DF"
        end
    end
    return ""
end

function Item:getShortName()
    return self.short_name or self:getName() 
end

function Item:getSeriousName()
    return self.serious_name or self:getShortName() 
end

function Item:battleUseSound(user, target)
end

function Item:onLightAttack(battler, enemy, damage, stretch, crit)
    if damage <= 0 then
        enemy:onDodge(battler, true)
    end
    -- local src = Assets.stopAndPlaySound(self.getLightAttackSound and self:getLightAttackSound() or "laz_c")
    local src = Assets.stopAndPlaySound(Game:isLight() and (self.getLightAttackSound and self:getLightAttackSound() or "laz_c") or battler.chara:getAttackSound() or "laz_c")
    -- src:setPitch(self.getLightAttackPitch and self:getLightAttackPitch() or 1)
    src:setPitch(Game:isLight() and (self.getLightAttackPitch and self:getLightAttackPitch() or 1) or battler.chara:getAttackPitch() or 1)
    -- local sprite = Sprite(self.getLightAttackSprite and self:getLightAttackSprite() or "effects/lightattack/strike")
    local sprite = Sprite(Game:isLight() and (self.getLightAttackSprite and self:getLightAttackSprite() or "effects/lightattack/strike") or battler.chara:getAttackSprite() or "effects/attack/cut") -- dark stuff here
    sprite.battler_id = battler and Game.battle:getPartyIndex(battler.chara.id) or nil
    table.insert(enemy.dmg_sprites, sprite)
    sprite:setOrigin(0.5)
    if Game:isLight() then -- dark stuff here
        sprite:setScale(stretch * 2 - 0.5)
        sprite.color = {battler.chara:getLightAttackColor()}
    else
        sprite:setScale(2)
    end
    local relative_pos_x, relative_pos_y = enemy:getRelativePos((enemy.width / 2) - (#Game.battle.attackers - 1) * 5 / 2 + (Utils.getIndex(Game.battle.attackers, battler) - 1) * 5, (enemy.height / 2) - 8)
    sprite:setPosition(relative_pos_x + enemy.dmg_sprite_offset[1], relative_pos_y + enemy.dmg_sprite_offset[2])
    sprite.layer = LIGHT_BATTLE_LAYERS["above_arena_border"]
    enemy.parent:addChild(sprite)
    -- sprite:play((stretch / 4) / 1.6, false, function(this)
    sprite:play(Game:isLight() and (stretch / 4) / 1.6 or 1/8, false, function(this) -- dark stuff here
        Game.battle.timer:after(3/30, function()
            self:onLightAttackHurt(battler, enemy, damage, stretch, crit, Game:isLight())
        end)
        
        this:remove()
        Utils.removeFromTable(enemy.dmg_sprites, this)
    end)
    return false
end

function Item:onLightMiss(battler, enemy, anim, show_status, attacked)
    enemy:hurt(0, battler, nil, nil, anim, show_status, attacked)
end

function Item:getLightBattleText(user, target)
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

function Item:onLightAttackHurt(battler, enemy, damage, stretch, crit, light, finish)
    local sound = enemy:getDamageSound() or "damage"
    if sound and type(sound) == "string" and (damage > 0 or enemy.always_play_damage_sound) then
        Assets.stopAndPlaySound(sound)
    end
    enemy:hurt(damage, battler)
    if light ~= false then
        battler.chara:onLightAttackHit(enemy, damage)
    else
        battler.chara:onAttackHit(enemy, damage)
    end
    if finish ~= false then
        Game.battle:finishActionBy(battler)
    end
end

function Item:canEquip(character, slot_type, slot_index)
    if self.light then
        return self.can_equip[character.id] ~= false
    else
        return super.canEquip(self, character, slot_type, slot_index)
    end
end

function Item:getHealBonus()
    return self.heal_bonus 
end

function Item:getLightBoltSpeedVariance()
    return self.light_bolt_speed_variance 
end

function Item:onLightBattleUse(user, target)
    self:battleUseSound(user, target)
    if self:getLightBattleText(user, target) then
        Game.battle:battleText(self:getLightBattleText(user, target))
    else
        Game.battle:battleText("* "..user.chara:getNameOrYou().." "..self:getUseMethod(user.chara).." the "..self:getUseName()..".")
    end
end

function Item:getEquipDisplayName()
    return self.equip_display_name or self:getName()
end

function Item:getInvBonus()
    return self.inv_bonus 
end

function Item:getFleeBonus()
    return self.flee_bonus 
end

function Item:getLightBoltCount()
    return self.light_bolt_count 
end

function Item:getLightBoltSpeed()
    if Game.battle.multi_mode then
        return nil
    else
        return self.light_bolt_speed + Utils.random(0, self:getLightBoltSpeedVariance(), 1)
    end
end

function Item:init()
    super.init(self)
    
    -- Short name for the light battle item menu
    self.short_name = nil
    -- Serious name for the light battle item menu
    self.serious_name = nil
    -- Dark name for the dark battle item menu
    self.dark_name = nil
    -- How this item is used on you (ate, drank, eat, etc.)
    self.use_method = "used"
    -- How this item is used on other party members (eats, etc.)
    self.use_method_other = nil
    
    -- Displays magic stats for weapons and armors in light shops
    self.shop_magic = false
    -- Doesn't display stats for weapons and armors in light shops
    self.shop_dont_show_change = false
    
    -- Whether this equipment item can convert on light change
    self.equip_can_convert = nil
    
    self.equip_display_name = nil
    
    self.heal_bonus = 0
    self.inv_bonus = 0
    self.flee_bonus = 0
    self.light_bolt_count = 1
    self.light_bolt_speed = 11
    self.light_bolt_speed_variance = 2
    
    self.light_bolt_acceleration = 0
    self.light_bolt_start = -16 -- number or table of where the bolt spawns. if it's a table, a value is chosen randomly
    self.light_multibolt_variance = nil
    self.light_bolt_direction = nil -- "right", "left", or "random"
    self.light_bolt_miss_threshold = nil -- (Defaults: 280 for slice weapons | 2 for shoe weapons)
    self.attack_sprite = "effects/lightattack/strike"
    -- Sound played when attacking, defaults to laz_c
    self.attack_sound = "laz_c"
    
    self.tags = {}
    self.attack_pitch = 1
end

function Item:getUseName()
    if self.light and Game.state == "BATTLE" and not Game.battle.light and self:getName() == self.dark_name then
        return self.use_name and self.use_name:upper() or self.name:upper()
    elseif (Game.state == "OVERWORLD" and Game:isLight()) or (Game.state == "BATTLE" and Game.battle.light)  then
        return self.use_name or self:getName()
    else
        return self.light and self.use_name and self.use_name:upper() or super.getUseName(self)
    end
end

function Item:getLightBoltAcceleration()
    return self.light_bolt_acceleration 
end

function Item:getLightBoltStart()
    if Game.battle.multi_mode then
        return nil
    elseif type(self.light_bolt_start) == "table" then
        return Utils.pick(self.light_bolt_start)
    elseif type(self.light_bolt_start) == "number" then
        return self.light_bolt_start
    end
end

function Item:getLightMultiboltVariance(index)
    if Game.battle.multi_mode or self.light_multibolt_variance == nil then
        return nil
    elseif type(self.light_multibolt_variance) == "number" then
        return self.light_multibolt_variance * index
    elseif self.light_multibolt_variance[index] then
        return type(self.light_multibolt_variance[index]) == "table" and Utils.pick(self.light_multibolt_variance[index]) or self.light_multibolt_variance[index]
    else
        return (type(self.light_multibolt_variance[#self.light_multibolt_variance]) == "table" and Utils.pick(self.light_multibolt_variance[#self.light_multibolt_variance]) or self.light_multibolt_variance[#self.light_multibolt_variance]) * (index - #self.light_multibolt_variance + 1)
    end
end

function Item:getLightBoltDirection()
    if self.light_bolt_direction == "random" or not self.light and self.light_bolt_direction == nil then
        return Utils.pick({"right", "left"})
    else
        return self.light_bolt_direction or "right"
    end
end

function Item:getLightAttackMissZone()
    return self.light_bolt_miss_threshold 
end

function Item:getLightAttackSprite()
    return self.attack_sprite 
end

function Item:getLightAttackSound()
    return self.attack_sound 
end

function Item:getLightAttackPitch()
    return self.attack_pitch 
end

return Item
