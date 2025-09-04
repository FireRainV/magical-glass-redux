---@class Savepoint : Savepoint
local Savepoint, super = Utils.hookScript(Savepoint)

function Savepoint:init(x, y, properties)
    super.init(self, x, y, properties)
    Game.world.timer:after(1/30, function()
        if Game:isLight() then
            self:setSprite("world/events/lightsavepoint", 1/6)
        end
    end)
end

function Savepoint:onTextEnd()
    if not Game:isLight() then
        super.onTextEnd(self)
    else
        if not self.world then return end
        if self.heals then
            for _,party in pairs(Game.party_data) do
                party:heal(math.huge, false)
            end
        end
        
        if self.simple_menu or (self.simple_menu == nil and not Kristal.getLibConfig("magical-glass", "expanded_light_save_menu")) then
            self.world:openMenu(LightSaveMenu(Game.save_id, self.marker))
        else
            self.world:openMenu(LightSaveMenuExpanded(self.marker))
        end
    end
end

function Savepoint:update()
    Interactable.update(self)

    if Game:isLight() and self.style == "deltarune" then
        self.sprite.alpha = 0.5

        if Game.world.player then
            local dist = Utils.dist(self.x, self.y, Game.world.player.x, Game.world.player.y)


            if dist <= 80 then
                self.sprite.alpha = math.min(1, ((1 - (dist/80)) + 0.5))
            end
        end
    end
end)

return Savepoint
