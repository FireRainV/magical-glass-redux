---@class BattleCutscene : BattleCutscene
local BattleCutscene, super = Utils.hookScript(BattleCutscene)

function BattleCutscene:text(text, portrait, actor, options)
    super.text(self, Game.battle.light and ("[shake:"..MagicalGlassLib.light_battle_shake_text.."]" .. text) or text, portrait, actor, options)
end

return BattleCutscene
