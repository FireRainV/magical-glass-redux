---@class LightCellMenu : LightCellMenu
local LightCellMenu, super = Utils.hookScript(LightCellMenu)

function LightCellMenu:runCall(call)
    super.runCall(self, call)
    if MagicalGlassLib.rearrange_cell_calls then
        table.insert(Game.world.calls, 1, Utils.removeFromTable(Game.world.calls, call))
    end
end

return LightCellMenu
