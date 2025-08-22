---@class Arena : Arena
local Arena, super = Utils.hookScript(Arena)

function Arena:init(x, y, shape)
    super.init(self, x, y, shape)
    if Game:isLight() then
        self.color = {1, 1, 1}
    end
end

return Arena
