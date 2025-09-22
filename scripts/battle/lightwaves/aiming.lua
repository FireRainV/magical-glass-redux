local Aiming, super = Class(LightWave)

function Aiming:onStart()
    -- Every 0.5 seconds...
    self.timer:every(1/2, function()

        if Game.battle.state == "DEFENDING" then
            -- Get all enemies that selected this wave as their attack
            local attackers = self:getAttackers()

            -- Loop through all attackers
            for _, attacker in ipairs(self:getAttackers()) do

                -- Get the attacker's center position
                local x, y = attacker:getRelativePos(attacker.width/2, attacker.height/2)

                -- Get the angle between the bullet position and the soul's position
                local angle = Utils.angle(x, y, Game.battle.soul.x, Game.battle.soul.y)

                -- Spawn smallbullet angled towards the player with speed 8 (see scripts/battle/bullets/smallbullet.lua)
                self:spawnBullet("smallbullet", x, y, angle, 8)
            end
        else
            -- Get all enemies that selected this wave as their attack
            local attackers = self:getMenuAttackers()

            -- Loop through all attackers
            for _, attacker in ipairs(self:getMenuAttackers()) do

                -- Get the attacker's center position
                local x, y = attacker:getRelativePos(attacker.width/2, attacker.height/2)

                -- Get the angle between the bullet position and the soul's position
                local angle = Utils.angle(x, y, Game.battle.soul.x, Game.battle.soul.y)

                -- Spawn smallbullet angled towards the player with speed 8 (see scripts/battle/bullets/smallbullet.lua)
                self:spawnBullet("smallbullet", x, y, angle, 8)
            end
        end
    end)
end

function Aiming:update()
    -- Code here gets called every frame

    super:update(self)
end

return Aiming