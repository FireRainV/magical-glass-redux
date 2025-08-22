---@class ActionBox : ActionBox
local ActionBox, super = Utils.hookScript(ActionBox)

function ActionBox:init(x, y, index, battler)
    super.init(self, x, y, index, battler)
    if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
        self.head_sprite:addFX(ShaderFX("color", {targetColor = MG_PALETTE["light_world_dark_battle_color"]}))
    end
end

return ActionBox
