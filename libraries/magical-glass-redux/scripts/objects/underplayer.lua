local UnderPlayer, super = Class(Player, "UnderPlayer")

function UnderPlayer:init(chara, x, y)
    super.init(self, chara, x, y)

    -- If 'true', the player will be unable to run, like in Undertale
    self.force_walk = not Kristal.getLibConfig("magical-glass", "undertale_movement_can_run")
    -- The movement speed of the player.
    self.walk_speed = Game:isLight() and 6 or 4
    
    -- Don't edit the stuff below
    self.dance = nil
    self.fix_movement = {false, false}
    self.can_move_x = true
    self.can_move_y = true
    self.event_collide = {}
    self.gone_direction = {}
    self.speed = 0
end

function UnderPlayer:handleMovement()
    local walk_x = 0
    local walk_y = 0
    
    local can_move_x = not self.last_collided_x
    local can_move_y = not self.last_collided_y
    
    local event_collide = self.event_collide["x"] or self.event_collide["y"] or false
    
    if Input.down("left") then
        walk_x = walk_x - 1
        if not (Input.down("up") and self.facing == "up" or Input.down("down") and self.facing == "down") then
            self.facing = "left"
        end
        if not can_move_x and can_move_y then
            if Input.down("up") then
                self.facing = "up"
            elseif Input.down("down") then
                self.facing = "down"
            end
        end
        if self.event_collide["x"] then
            self.gone_direction["left"] = true
        end
    elseif Input.down("right") then
        walk_x = walk_x + 1
        if not (Input.down("up") and self.facing == "up" or Input.down("down") and self.facing == "down") then
            self.facing = "right"
        end
        if not can_move_x and can_move_y then
            if Input.down("up") then
                self.facing = "up"
            elseif Input.down("down") then
                self.facing = "down"
            end
        end
        if self.event_collide["x"] then
            self.gone_direction["right"] = true
        end
    end

    if Input.down("up") then
        walk_y = walk_y - 1
        if not (Input.down("left") and self.facing == "left" or Input.down("right") and self.facing == "right") then
            self.facing = "up"
        end
        if not can_move_y and can_move_x then
            if Input.down("left") then
                self.facing = "left"
            elseif Input.down("right") then
                self.facing = "right"
            end
        end
        if self.event_collide["y"] then
            self.gone_direction["up"] = true
        end
    elseif Input.down("down") then
        walk_y = walk_y + 1
        if not (Input.down("left") and self.facing == "left" or Input.down("right") and self.facing == "right") then
            self.facing = "down"
        end
        if not can_move_y and can_move_x then
            if Input.down("left") then
                self.facing = "left"
            elseif Input.down("right") then
                self.facing = "right"
            end
        end
        if self.event_collide["y"] then
            self.gone_direction["down"] = true
        end
    end
   
    self.moving_x = walk_x
    self.moving_y = walk_y

    local running = (Input.down("cancel") or self.force_run) and not self.force_walk
    if Kristal.Config["autoRun"] and not self.force_run and not self.force_walk then
        running = not running
    end

    self.speed = self.walk_speed
    if running then
        self.speed = self.speed + 5
    end
    
    if Input.down("up") and Input.down("down") then
        if not can_move_y then
            if self.dance == nil then
                self.dance = false
            end
        else
            self.dance = true
        end
        if self.dance and not can_move_y then
            self.facing = "up"
        end
    else
        self.dance = nil
    end
    
    if self.gone_direction["left"] and not Input.down("left") then
        self.gone_direction["left"] = false
        self.fix_movement[2] = true
    end
    if self.gone_direction["right"] and not Input.down("right") then
        self.gone_direction["right"] = false
        self.fix_movement[2] = true
    end
    if self.gone_direction["up"] and not Input.down("up") then
        self.gone_direction["up"] = false
        self.fix_movement[2] = true
    end
    if self.gone_direction["down"] and not Input.down("down") then
        self.gone_direction["down"] = false
        self.fix_movement[2] = true
    end

    if not self.fix_movement[2] and event_collide and self.moving_x ~= 0 and self.moving_y ~= 0 then
        self.facing = self.sprite.facing
    elseif not (Input.down("up") and Input.down("down") and not can_move_x and self.moving_x ~= 0) or self.fix_movement[1] and self.fix_movement[1] ~= self.moving_x then
        self:move(walk_x, walk_y, self.speed * DTMULT)
        self.fix_movement = {false, false}
    else
        self.facing = "down"
        self.fix_movement[1] = self.moving_x
    end
    
    self.sprite.facing = self.facing
end

function UnderPlayer:doMoveAmount(type, amount, other_amount)
    other_amount = other_amount or 0
    self.event_collide[type] = false

    if amount == 0 then
        self["last_collided_"..type] = false
        return false, false
    end

    local other = type == "x" and "y" or "x"

    local sign = Utils.sign(amount)
    for i = 1, math.ceil(math.abs(amount)) do
        local moved = sign
        if (i > math.abs(amount)) then
            moved = (math.abs(amount) % 1) * sign
        end

        local last_a = self[type]
        local last_b = self[other]

        self[type] = self[type] + moved

        if (not self.noclip) and (not NOCLIP) then
            Object.startCache()
            local collided, target = self.world:checkCollision(self.collider, self.enemy_collision)
            if collided and not (other_amount > 0) then
                for j = 1, 2 do
                    Object.uncache(self)
                    self[other] = self[other] - j
                    collided, target = self.world:checkCollision(self.collider, self.enemy_collision)
                    if not collided then break end
                end
            end
            if collided and not (other_amount < 0) then
                self[other] = last_b
                for j = 1, 2 do
                    Object.uncache(self)
                    self[other] = self[other] + j
                    collided, target = self.world:checkCollision(self.collider, self.enemy_collision)
                    if not collided then break end
                end
            end
            Object.endCache()

            self.can_move_x = true
            self.can_move_y = true

            if collided then
                self[type] = last_a
                self[other] = last_b

                if not target:includes("Event") then
                    if self.moving_y < 0 and (Input.down("up") and Input.down("down")) then
                        if not self["last_collided_"..other] == true then
                            self[type] = self[type] + self.speed
                        end
                        self.facing = "down"
                        self.sprite.facing = self.facing
                        local collided, target = self.world:checkCollision(self.collider, self.enemy_collision)
                        if collided and not (other_amount > 0) then
                            self[type] = last_a
                        end
                    end
                else
                    self.event_collide[type] = true
                    if (Input.down("down")) then
                        self.sprite.facing = self.facing
                        self.can_move_x = false
                        if (Input.down("right")) then
                            self.sprite.facing = self.facing
                            self.can_move_y = false
                        end
                        if (Input.down("left")) then
                            self.sprite.facing = self.facing
                            self.can_move_y = false
                        end
                    end
                    if (Input.down("up")) then
                        self.sprite.facing = self.facing
                        self.can_move_x = false
                        if (Input.down("right")) then
                            self.sprite.facing = self.facing
                            self.can_move_y = false
                        end
                        if (Input.down("left")) then
                            self.sprite.facing = self.facing
                            self.can_move_y = false
                        end
                    end
                    if (Input.down("right")) then
                        self.sprite.facing = self.facing
                        self.can_move_y = false
                    end
                    if (Input.down("left")) then
                        self.sprite.facing = self.facing
                        self.can_move_y = false
                    end
                end

                if target and target.onCollide then
                    target:onCollide(self)
                end

                self["last_collided_"..type] = true
                return i > 1, target
            end
        end
    end
    self["last_collided_"..type] = false
    return true, false
end

function UnderPlayer:move(x, y, speed, keep_facing)
    local movex, movey = x * (speed or 1), y * (speed or 1)

    local moved = false
    moved = self:moveX(movex, movey) or moved
    moved = self:moveY(movey, movex) or moved

    if moved then
        self.moved = math.max(self.moved, math.max(math.abs(movex) / DTMULT, math.abs(movey) / DTMULT))

        self.sprite.walking = true
        self.sprite.walk_speed = self.moved > 0 and math.max(4, self.moved) or 0
    end

    return moved
end

function UnderPlayer:update()
    if not self["last_collided_x"] == true then
        self.can_move_y = true
    end
    if not self["last_collided_y"] == true then
        self.can_move_x = true
    end
    super.update(self)
end

return UnderPlayer