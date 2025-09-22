local bullet, super = Class(Bullet)

function bullet:init(x, y)
    super:init(self, x, y, "bullets/froggit/leapfrog_idle")

    self:setScale(1, 1)
    self:setOrigin(0.5, 1)

    self.physics.direction = -math.rad(145 - Utils.random(20))
    self.physics.gravity_direction = math.rad(90)
    
    -- Whether the bullet deals bonus damage when having more HP (Light Battles only)
    self.bonus_damage = false
end

function bullet:jump()
    self.damage = self:getDamage() * 1.8
    self:setSprite("bullets/froggit/leapfrog_jump")
    self.physics.gravity = 0.4
    self.physics.speed = 7 + Utils.random(3)
end

function bullet:onCollide(soul)
    super.onCollide(self, soul)
    self.collided = true
end

return bullet