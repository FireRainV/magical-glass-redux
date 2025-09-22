local bullet, super = Class(Bullet)

function bullet:init(x, y)
    super.init(self, x, y, "bullets/froggit/bulletsm")

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
    
    -- Whether the bullet deals bonus damage when having more HP (Light Battles only)
    self.bonus_damage = false
end

return bullet