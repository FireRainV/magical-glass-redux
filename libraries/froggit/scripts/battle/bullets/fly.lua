local bullet, super = Class(Bullet)

function bullet:init(x, y)
    super.init(self, x, y)
    self.remove_outside_of_arena = true

    self:setSprite("bullets/froggit/flybullet", 2/30, true)

    self:setScale(1, 1)
    self:setOrigin(0.5, 0.5)
    self:setHitbox(5, 5, 4, 4)

    local particle = Sprite("bullets/froggit/bulletgenmd")
    particle:setOrigin(0.5, 0.5)
    Game.battle:addChild(particle)
    particle.layer = BATTLE_LAYERS["top"]
    local rx, ry = particle:getRelativePos(x, y)
    particle:setPosition(rx, ry + 8)
    particle:play(1/30, false, function(this) this:remove() end)

    local angle = Utils.angle(x, y, Game.battle.soul.x + 2, Game.battle.soul.y + 2)
    self.physics.direction = angle
    self.physics.speed = 2.5

    Game.battle.timer:every(1.1, function()
        self.physics.speed = 0
        local new_angle = Utils.angle(self.x, self.y, Game.battle.soul.x + 2, Game.battle.soul.y + 2)
        self.physics.direction = new_angle
    end)

    Game.battle.timer:every(1.5, function()
        self.physics.speed = 3
    end)
    
    -- Whether the bullet deals bonus damage when having more HP (Light Battles only)
    self.bonus_damage = false
end

return bullet