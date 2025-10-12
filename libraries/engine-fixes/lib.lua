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
end

return lib