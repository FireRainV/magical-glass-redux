---@class Soul : Soul
local Soul, super = Utils.hookScript(Soul)

function Soul:init(x, y, color)
    super.init(self, x, y, color)
    self.speed = self.speed + Game.battle.soul_speed_bonus
    if not Kristal.getLibConfig("magical-glass", "light_world_dark_battle_tension") and Game:isLight() then
        self.graze_collider.collidable = false
    end
end

return Soul
