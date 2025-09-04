---@class DebugSystem : DebugSystem
local DebugSystem, super = Utils.hookScript(DebugSystem)

function DebugSystem:update()
    super.update(self)
    if self:isMenuOpen() then
        for state,menus in pairs(self.exclusive_battle_menus) do
            if state == "DARKBATTLE" then
                state = false
            elseif state == "LIGHTBATTLE" then
                state = true
            end
            if Utils.containsValue(menus, self.current_menu) and type(state) == "boolean" and Game.battle and Game.battle.light ~= state then
                self:refresh()
            end
        end
        for state,menus in pairs(self.exclusive_world_menus) do
            if state == "DARKWORLD" then
                state = false
            elseif state == "LIGHTWORLD" then
                state = true
            end
            if Utils.containsValue(menus, self.current_menu) and type(state) == "boolean" and Game:isLight() ~= state then
                self:refresh()
            end
        end
    end
end

return DebugSystem
