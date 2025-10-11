local lib = {}

function lib:save(data)
    data.calls = Game.world.calls
end

function lib:load(data, new_file)
    Game.world.calls = {}
    if data.calls then
        Game.world.calls = data.calls
    end
end

function lib:init()
    Utils.hook(PartyBattler, "hurt", function(orig, self, amount, exact, color, options)
        options = options or {}
        
        Game.battle:shakeCamera(4)

        local swoon = options["swoon"]

        if not options["all"] then
            Assets.playSound("hurt")
            if not exact then
                amount = self:calculateDamage(amount)
                if self.defending then
                    amount = math.ceil((2 * amount) / 3)
                end
                -- we don't have elements right now
                local element = 0
                amount = math.ceil((amount * self:getElementReduction(element)))
            end

            self:removeHealth(amount, swoon)
        else
            -- We're targeting everyone.
            if not exact then
                amount = self:calculateDamage(amount)
                -- we don't have elements right now
                local element = 0
                amount = math.ceil((amount * self:getElementReduction(element)))

                if self.defending then
                    amount = math.ceil((3 * amount) / 4) -- Slightly different than the above
                end
            end

            self:removeHealthBroken(amount, swoon) -- Use a separate function for cleanliness
        end

        if (self.chara:getHealth() <= 0) then
            self:statusMessage("msg", swoon and "swoon" or "down", color, true)
        else
            self:statusMessage("damage", amount, color, true)
        end

        self.hurt_timer = 0

        if (not self.defending) and (not self.is_down) then
            self.sleeping = false
            self.hurting = true
            self:toggleOverlay(true)
            self.overlay_sprite:setAnimation("battle/hurt", function()
                if self.hurting then
                    self.hurting = false
                    self:toggleOverlay(false)
                end
            end)
            if not self.overlay_sprite.anim_frames then -- backup if the ID doesn't animate, so it doesn't get stuck with the hurt animation
                Game.battle.timer:after(0.5, function()
                    if self.hurting then
                        self.hurting = false
                        self:toggleOverlay(false)
                    end
                end)
            end
        end
    end)
    
    Utils.hook(World, "hurtParty", function(orig, self, battler, amount)
        Assets.playSound("hurt")

        self:shakeCamera()
        self:showHealthBars()

        if type(battler) == "number" then
            amount = battler
            battler = nil
        end

        local any_killed = false
        local any_alive = false
        for _,party in ipairs(Game.party) do
            if not battler or battler == party.id or battler == party then
                local current_health = party:getHealth()
                party:setHealth(party:getHealth() - amount)
                if party:getHealth() <= 0 then
                    party:setHealth(1)
                    any_killed = true
                else
                    any_alive = true
                end

                local dealt_amount = current_health - party:getHealth()

                if dealt_amount > 0 then
                    self:getPartyCharacterInParty(party):statusMessage("damage", dealt_amount)
                end
            elseif party:getHealth() > amount then
                any_alive = true
            end
        end

        if self.player then
            self.player.hurt_timer = 7
        end

        if any_killed and not any_alive then
            for _,party in ipairs(Game.party) do
                if party:getHealth() > 0 then
                    party:setHealth(0)
                end
            end
            self:shakeCamera(0)
            if not self.map:onGameOver() then
                Game:gameOver(self.soul:getScreenPos())
            end
            return true
        elseif battler then
            return any_killed
        end

        return false
    end)
    
    -- Replaces a phone call in the Light World CELL menu with another
    Utils.hook(World, "replaceCall", function(orig, self, replace_name, name, scene)
        for i,call in ipairs(self.calls) do
            if call[1] == replace_name then
                self.calls[i] = {name, scene}
                break
            end
        end
    end)
    
    -- Removes a phone call in the Light World CELL menu
    Utils.hook(World, "removeCall", function(orig, self, name)
        for i,call in ipairs(self.calls) do
            if call[1] == name then
                table.remove(self.calls, i)
                break
            end
        end
    end)
    
    -- Removes all the phone calls in the Light World CELL menu
    Utils.hook(World, "clearCalls", function(orig, self)
        self.calls = {}
    end)
    
    Utils.hook(Game, "gameOver", function(orig, self, x, y, redraw)
        if redraw or (redraw == nil and Game:isLight()) then
            love.draw() -- Redraw the frame so the screenshot will use an updated draw data
        end
        orig(self, x, y, redraw)
    end)
    
    Utils.hook(PartyMember, "init", function(orig, self)
        -- Message will show even if the member is the soul character
        self.force_gameover_message = false
        
        -- The number of times that this party member got stronger (saved to the save file)
        self.level_up_count = 0
        
        -- Battle soul position offset (optional)
        self.soul_offset = nil
        
        orig(self)
    end)
    
    Utils.hook(PartyMember, "getForceGameOverMessage", function(orig, self)
        return self.force_gameover_message
    end)
    
    Utils.hook(PartyMember, "getSoulOffset", function(orig, self)
        return unpack(self.soul_offset or {0, 0})
    end)
    
    Utils.hook(Encounter, "getSoulSpawnLocation", function(orig, self)
        local main_chara = Game:getSoulPartyMember()

        if main_chara and main_chara:getSoulPriority() >= 0 then
            local battler = Game.battle.party[Game.battle:getPartyIndex(main_chara.id)]

            if battler then
                local offset_x, offset_y = main_chara:getSoulOffset()
                return battler:localToScreenPos(battler.sprite.width/2 - 4.5 + offset_x, battler.sprite.height/2 + offset_y)
            end
        end
        return -9, -9
    end)
    
    Utils.hook(PartyMember, "onSave", function(orig, self, data)
        orig(self, data)
        data["level_up_count"] = self.level_up_count
    end)
    
    Utils.hook(PartyMember, "onLoad", function(orig, self, data)
        orig(self, data)
        self.level_up_count = data.level_up_count or self.level_up_count
    end)
end

return lib