---@class World : World
local World, super = Utils.hookScript(World)

function World:heal(target, amount, text, item)
    if Game:isLight() then
        MagicalGlassLib.heal_amount = amount
        
        if type(target) == "string" then
            target = Game:getPartyMember(target)
        end
        local maxed = target:heal(amount, false)
        if text and item and item.getLightWorldHealingText and item:getLightWorldHealingText(target, amount, maxed) then
            if type(text) == "table" then
                text[#text] = text[#text] .. (text[#text] ~= "" and "\n" or "") .. item:getLightWorldHealingText(target, amount, maxed)
            else
                text = text .. (text ~= "" and "\n" or "") .. item:getLightWorldHealingText(target, amount, maxed)
            end
        end
        
        if text then
            if not Game.world:hasCutscene() then
                Game.world:showText(text)
            end
        else
            Assets.stopAndPlaySound("power")
        end
    else
        super.heal(self, target, amount, text)
    end
end

function World:showHealthBars()
    if Game:isLight() then
        if self.healthbar then
            self.healthbar:transitionIn()
        else
            self.healthbar = LightHealthBar()
            self.healthbar.layer = WORLD_LAYERS["ui"] + 1
            self:addChild(self.healthbar)
        end
    else
        super.showHealthBars(self)
    end
end

function World:onKeyPressed(key)
    super.onKeyPressed(self, key)
    if Kristal.Config["debug"] and Input.ctrl() then
        if key == "s" and Game:isLight() then
            -- close the old one
            self.menu:remove()
            self:closeMenu()
            
            local save_pos = nil
            if Input.shift() then
                save_pos = {self.player.x, self.player.y}
            end
            if not Kristal.getLibConfig("magical-glass", "expanded_light_save_menu") then
                self:openMenu(LightSaveMenu(Game.save_id, save_pos))
            else
                self:openMenu(LightSaveMenuExpanded(save_pos))
            end
        end
    end
end

function World:loadMap(...) -- Punch Card Exploit Emulation)
    if MagicalGlassLib.exploit then
        self:stopCutscene()
    end
    super.loadMap(self, ...)
    MagicalGlassLib.map_transitioning = false
    if MagicalGlassLib.viewing_image then
        local facing = Game.world.player and Game.world.player.facing or "down"
        for _,party in ipairs(Utils.mergeMultiple(Game.stage:getObjects(Player), Game.stage:getObjects(Follower))) do
            party:remove()
        end
        self:spawnParty("spawn", nil, nil, facing)
    end
    MagicalGlassLib.viewing_image = false
end

function World:mapTransition(...)
    super.mapTransition(self, ...)
    MagicalGlassLib.map_transitioning = true
    MagicalGlassLib.steps_until_encounter = nil
    if MagicalGlassLib.initiating_random_encounter then
        Game.lock_movement = false
        MagicalGlassLib.initiating_random_encounter = nil
    end
end

function World:spawnPlayer(...)
    local args = {...}
    local x, y = 0, 0
    local chara = self.player and self.player.actor
    local party
    if #args > 0 then
        if type(args[1]) == "number" then
            x, y = args[1], args[2]
            chara = args[3] or chara
            party = args[4]
        elseif type(args[1]) == "string" then
            x, y = self.map:getMarker(args[1])
            chara = args[2] or chara
            party = args[3]
        end
    end
    if type(chara) == "string" then
        chara = Registry.createActor(chara)
    end
    local facing = "down"
    if self.player then
        facing = self.player.facing
        self:removeChild(self.player)
    end
    if self.soul then
        self:removeChild(self.soul)
    end
    
    if Game.party[1]:getUndertaleMovement() then
        self.player = UnderPlayer(chara, x, y)
    else
        self.player = Player(chara, x, y)
    end
    self.player.layer = self.map.object_layer
    self.player:setFacing(facing)
    self:addChild(self.player)
    
    if party then
        self.player.party = party
    end
    self.soul = OverworldSoul(self.player:getRelativePos(self.player.actor:getSoulOffset()))
    self.soul:setColor(Game:getSoulColor())
    if Mod.libs["multiplayer"] and Game.party[1] then
        self.soul:setColor(Game.party[1]:getColor())
        if Game.party[1].soul_priority < 2 then
            self.soul.rotation = math.pi
        end
    end
    
    self.soul.layer = WORLD_LAYERS["soul"]
    self:addChild(self.soul)
    if self.camera.attached_x then
        self.camera:setPosition(self.player.x, self.camera.y)
    end
    if self.camera.attached_y then
        self.camera:setPosition(self.camera.x, self.player.y - (self.player.height * 2)/2)
    end
end

function World:lightShopTransition(shop, options)
    self:fadeInto(function()
        MagicalGlassLib:enterLightShop(shop, options)
    end)
end

return World
