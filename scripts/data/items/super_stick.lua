local item, super = Class(LightEquipItem, "test/super_stick")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Super Stick"
    self.short_name = "SprStick"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 151

    -- Item description text (unused by light items outside of debug menu)
    self.description = "Attacks Twice!"

    -- Light world check text
    self.check = "Weapon AT 0\n* Attacks Twice!"

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    
    self.attacks_amount = 2
end

function item:onLightAttack(battler, enemy, damage, stretch)
    if damage <= 0 then
        enemy:onDodge(battler, true)
    end
    self.counter = 0
    Game.battle.timer:everyInstant(stretch / 1.5, function()
        self.counter = self.counter + 1
        local src = Assets.stopAndPlaySound(self.getLightAttackSound and self:getLightAttackSound() or "laz_c") 
        src:setPitch(self.getLightAttackPitch and self:getLightAttackPitch() or 1)
    
        local sprite = Sprite(self.getLightAttackSprite and self:getLightAttackSprite() or "effects/attack/strike")
        sprite.rotation = math.rad(self.counter % 2 == 1 and -45 or 45)
        sprite.battler_id = battler and Game.battle:getPartyIndex(battler.chara.id) or nil
        table.insert(enemy.dmg_sprites, sprite)
        sprite:setScale(stretch * 2 - 0.5)
        sprite:setOrigin(0.5)
        local relative_pos_x, relative_pos_y = enemy:getRelativePos((enemy.width / 2) - (#Game.battle.attackers - 1) * 5 / 2 + (Utils.getIndex(Game.battle.attackers, battler) - 1) * 5, (enemy.height / 2) - 8)
        sprite:setPosition(relative_pos_x + enemy.dmg_sprite_offset[1], relative_pos_y + enemy.dmg_sprite_offset[2])
        sprite.layer = BATTLE_LAYERS["above_ui"] + 5
        sprite.color = {battler.chara:getLightAttackColor()}
        enemy.parent:addChild(sprite)
        sprite:play((stretch^(1/1.5) / 4) / 1.5, false, function(this)
            local sound = enemy:getDamageSound() or "damage"
            if sound and type(sound) == "string" and (damage > 0 or enemy.always_play_damage_sound) then
                Assets.stopAndPlaySound(sound)
            end
            enemy:hurt(damage, battler)

            battler.chara:onLightAttackHit(enemy, damage)
            this:remove()
            Utils.removeFromTable(enemy.dmg_sprites, this)
            
            if self.counter >= self.attacks_amount then
                Game.battle:finishActionBy(battler)
            end
        end)
    end, self.attacks_amount)

    return false
end

return item