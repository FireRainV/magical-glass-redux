---@class Game : Game
local Game, super = Utils.hookScript(Game)

function Game:encounter(encounter, transition, enemy, context, light)
    if MagicalGlassLib.current_battle_system then
        if MagicalGlassLib.current_battle_system == "undertale" then
            Game:encounterLight(encounter, transition, enemy, context)
        else
            super.encounter(self, encounter, transition, enemy, context)
        end
    elseif context and isClass(context) and context:includes(ChaserEnemy) then
        if context.light_encounter then
            MagicalGlassLib.current_battle_system = "undertale"
            Game:encounterLight(encounter, transition, enemy, context)
        else
            MagicalGlassLib.current_battle_system = "deltarune"
            super.encounter(self, encounter, transition, enemy, context)
        end
    elseif light ~= nil then
        if light then
            MagicalGlassLib.current_battle_system = "undertale"
            Game:encounterLight(encounter, transition, enemy, context)
        else
            MagicalGlassLib.current_battle_system = "deltarune"
            super.encounter(self, encounter, transition, enemy, context)
        end
    else
        if Kristal.getLibConfig("magical-glass", "default_battle_system")[1] == "undertale" then
            MagicalGlassLib.current_battle_system = "undertale"
            Game:encounterLight(encounter, transition, enemy, context)
        else
            MagicalGlassLib.current_battle_system = "deltarune"
            super.encounter(self, encounter, transition, enemy, context)
        end
    end
end

function Game:encounterLight(encounter, transition, enemy, context)
    if transition == nil then transition = true end
    if self.battle then
        error("Attempt to enter light battle while already in battle")
    end
    
    if enemy and not isClass(enemy) then
        self.encounter_enemies = enemy
    else
        self.encounter_enemies = {enemy}
    end
    self.state = "BATTLE"
    self.battle = LightBattle()
    if context then
        self.battle.encounter_context = context
    end
    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "INTRO", encounter)
    end
    self.stage:addChild(self.battle)
end

function Game:gameOver(x, y)
    super.gameOver(self, x, y)
    MagicalGlassLib:setGameOvers((MagicalGlassLib:getGameOvers() or 0) + 1)
end

function Game:enterShop(shop, options, light)
    if MagicalGlassLib.in_light_shop or light then
        MagicalGlassLib:enterLightShop(shop, options)
    else
        super.enterShop(self, shop, options)
    end
end

function Game:setupShop(shop)
    local check_shop
    if type(shop) == "string" then
        check_shop = Registry.getShop(shop)
    else
        check_shop = shop
    end
    
    if check_shop:includes(LightShop) then
        error("Attempted to use LightShop in a Shop. Convert the shop file to a Shop")
    end
    
    super.setupShop(self, shop)
end

return Game
