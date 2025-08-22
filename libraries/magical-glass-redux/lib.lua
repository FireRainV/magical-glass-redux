TweenManager             = libRequire("magical-glass", "scripts/tweenmanager")
LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightPartyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightpartybattler")
LightEnemyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightenemybattler")
LightEnemySprite         = libRequire("magical-glass", "scripts/lightbattle/lightenemysprite")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
LightEncounter           = libRequire("magical-glass", "scripts/lightbattle/lightencounter")
LightSoul                = libRequire("magical-glass", "scripts/lightbattle/lightsoul")
LightWave                = libRequire("magical-glass", "scripts/lightbattle/lightwave")
LightBattleUI            = libRequire("magical-glass", "scripts/lightbattle/ui/lightbattleui")
HelpWindow               = libRequire("magical-glass", "scripts/lightbattle/ui/helpwindow")
LightDamageNumber        = libRequire("magical-glass", "scripts/lightbattle/ui/lightdamagenumber")
LightGauge               = libRequire("magical-glass", "scripts/lightbattle/ui/lightgauge")
LightTensionBar          = libRequire("magical-glass", "scripts/lightbattle/ui/lighttensionbar")
LightActionButton        = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbutton")
LightActionBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbox")
LightAttackBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbox")
LightAttackBar           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbar")
LightStatusDisplay       = libRequire("magical-glass", "scripts/lightbattle/ui/lightstatusdisplay")
LightShop                = libRequire("magical-glass", "scripts/lightshop")
RandomEncounter          = libRequire("magical-glass", "scripts/randomencounter")

MagicalGlassLib = {}
local lib = MagicalGlassLib
-- Mod.libs["magical-glass"]

function lib:unload()
    MagicalGlassLib          = nil
    MG_PALETTE               = nil
    MG_EVENT                 = nil
    LIGHT_BATTLE_LAYERS      = nil
    
    TweenManager             = nil
    LightBattle              = nil
    LightPartyBattler        = nil
    LightEnemyBattler        = nil
    LightEnemySprite         = nil
    LightArena               = nil
    LightEncounter           = nil
    LightSoul                = nil
    LightWave                = nil
    LightBattleUI            = nil
    HelpWindow               = nil
    LightDamageNumber        = nil
    LightGauge               = nil
    LightTensionBar          = nil
    LightActionButton        = nil
    LightActionBox           = nil
    LightAttackBox           = nil
    LightAttackBar           = nil
    LightStatusDisplay       = nil
    LightShop                = nil
    RandomEncounter          = nil
    
    Textbox.REACTION_X_BATTLE = ORIG_REACTION_X_BATTLE
    Textbox.REACTION_Y_BATTLE = ORIG_REACTION_Y_BATTLE
    ORIG_REACTION_X_BATTLE = nil
    ORIG_REACTION_Y_BATTLE = nil
end

function lib:save(data)
    data.magical_glass = {}
    data.magical_glass["kills"] = lib.kills
    data.magical_glass["serious_mode"] = lib.serious_mode
    data.magical_glass["spare_color"] = lib.spare_color
    data.magical_glass["spare_color_name"] = lib.spare_color_name
    data.magical_glass["save_level"] = Game.party[1] and Game.party[1]:getLightLV() or 0
    data.magical_glass["in_light_shop"] = lib.in_light_shop
    data.magical_glass["current_battle_system"] = lib.current_battle_system
    data.magical_glass["random_encounter"] = lib.random_encounter
    data.magical_glass["light_battle_shake_text"] = lib.light_battle_shake_text
    data.magical_glass["rearrange_cell_calls"] = lib.rearrange_cell_calls
end

function lib:load(data, new_file)
    if not love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        love.filesystem.write("saves/" .. Mod.info.id .. "/global.json", self:initGlobalSave())
    end
    
    Game.light = Kristal.getLibConfig("magical-glass", "default_battle_system")[2] or false
    
    data.magical_glass = data.magical_glass or {}
    lib.kills = data.magical_glass["kills"] or 0
    lib.serious_mode = data.magical_glass["serious_mode"] or false
    lib.spare_color = data.magical_glass["spare_color"] or COLORS.yellow
    lib.spare_color_name = data.magical_glass["spare_color_name"] or "YELLOW"
    lib.in_light_shop = data.magical_glass["in_light_shop"] or false
    lib.current_battle_system = data.magical_glass["current_battle_system"] or nil
    lib.random_encounter = data.magical_glass["random_encounter"] or nil
    lib.light_battle_shake_text = data.magical_glass["light_battle_shake_text"] or 0
    lib.rearrange_cell_calls = data.magical_glass["rearrange_cell_calls"] or false
    
    if new_file then
        self:setGameOvers(0)
        
        lib.initialize_armor_conversion = true
        if not Kristal.getLibConfig("magical-glass", "item_conversion") then
            Game:setFlag("has_cell_phone", Kristal.getModOption("cell") ~= false)
        end
    else
        self:setGameOvers(self:getGameOvers() or 0)
        
        for _,party in pairs(Game.party_data) do -- Fixes a crash with existing saves
            if not party.lw_stats["magic"] then
                party:reloadLightStats()
            end
        end
        
    end
end

-- GLOBAL SAVE

local read = love.filesystem.read
local write = love.filesystem.write

function lib:initGlobalSave()
    local data = {}

    data["global"] = {}

    data["files"] = {}
    for i = 1, 3 do
        data["files"][i] = {}
    end

    return JSON.encode(data)
end

function lib:setGameOvers(amount)
    lib.game_overs = amount
    lib:writeToGlobalSaveFile("game_overs", lib.game_overs)
end

function lib:getGameOvers()
    return lib:readFromGlobalSaveFile("game_overs")
end

function lib:writeToGlobalSaveFile(key, data, file)
    file = file or Game.save_id
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        global_data.files[file][key] = data
        write("saves/" .. Mod.info.id .. "/global.json", JSON.encode(global_data))
    end
end

function lib:writeToGlobalSave(key, data)
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        global_data.global[key] = data
        write("saves/" .. Mod.info.id .. "/global.json", JSON.encode(global_data))
    end
end

function lib:readFromGlobalSaveFile(key, file)
    file = file or Game.save_id
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        return global_data.files[file][key]
    end
end

function lib:readFromGlobalSave(key)
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        return global_data.global[key]
    end
end

function lib:clearGlobalSave()
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        love.filesystem.write("saves/" .. Mod.info.id .. "/global.json", self:initGlobalSave())
    end
end

function lib:preInit()
    ORIG_REACTION_X_BATTLE = Textbox.REACTION_X_BATTLE
    ORIG_REACTION_Y_BATTLE = Textbox.REACTION_Y_BATTLE
    
    MG_PALETTE = {
        ["tension_maxtext"] = PALETTE["tension_maxtext"],
        ["tension_back"] = PALETTE["tension_back"],
        ["tension_decrease"] = PALETTE["tension_decrease"],
        ["tension_fill"] = PALETTE["tension_fill"],
        ["tension_max"] = PALETTE["tension_max"],
        
        ["tension_desc"] = PALETTE["tension_desc"],

        ["tension_back_reduced"] = PALETTE["tension_back_reduced"],
        ["tension_decrease_reduced"] = PALETTE["tension_decrease_reduced"],
        ["tension_fill_reduced"] = PALETTE["tension_fill_reduced"],
        ["tension_max_reduced"] = PALETTE["tension_max_reduced"],
        
        ["action_health_bg"] = COLORS.red,
        ["action_health"] = COLORS.lime,
        ["action_health_text"] = PALETTE["action_health_text"],
        ["battle_mercy_bg"] = PALETTE["battle_mercy_bg"],
        ["battle_mercy_text"] = PALETTE["battle_mercy_text"],
        
        ["gauge_outline"] = COLORS.black,
        ["gauge_bg"] = {64/255, 64/255, 64/255, 1},
        ["gauge_health"] = COLORS.lime,
        ["gauge_mercy"] = COLORS.yellow,
        
        ["pink_spare"] = {255/255, 187/255, 212/255, 1},
        
        ["player_health_bg"] = COLORS.red,
        ["player_health"] = COLORS.yellow,
        ["player_karma_health_bg"] = {192/255, 0, 0, 1},
        ["player_karma_health"] = COLORS.fuchsia,
        
        ["player_health_bg_dark"] = PALETTE["action_health_bg"],
        ["player_karma_health_dark"] = COLORS.silver,
        
        ["player_text"] = COLORS.white,
        ["player_defending_text"] = COLORS.aqua,
        ["player_action_text"] = COLORS.yellow,
        ["player_down_text"] = COLORS.red,
        ["player_sleeping_text"] = COLORS.blue,
        ["player_karma_text"] = COLORS.fuchsia,
        
        ["light_world_dark_battle_color"] = COLORS.white,
        ["light_world_dark_battle_color_attackbar"] = COLORS.lime,
        ["light_world_dark_battle_color_attackbox"] = {0.5, 0, 0, 1},
        ["light_world_dark_battle_color_damage_single"] = COLORS.white,
    }
    
    MG_EVENT = {
        onLightBattleActionBegin = "onLightBattleActionBegin",
        onLightBattleActionEnd = "onLightBattleActionEnd",
        onLightBattleActionCommit = "onLightBattleActionCommit",
        onLightBattleActionUndo = "onLightBattleActionUndo",
        onLightBattleMenuSelect = "onLightBattleMenuSelect",
        onLightBattleMenuCancel = "onLightBattleMenuCancel",
        onLightBattleEnemySelect = "onLightBattleEnemySelect",
        onLightBattleEnemyCancel = "onLightBattleEnemyCancel",
        onLightBattlePartySelect = "onLightBattlePartySelect",
        onLightBattlePartyCancel = "onLightBattlePartyCancel",
        onLightActionSelect = "onLightActionSelect",
        
        onRegisterRandomEncounters = "onRegisterRandomEncounters",
        onRegisterLightEncounters = "onRegisterLightEncounters",
        onRegisterLightEnemies = "onRegisterLightEnemies",
        onRegisterLightWaves = "onRegisterLightWaves",
        onRegisterLightShops = "onRegisterLightShops",
    }
    
    LIGHT_BATTLE_LAYERS = {
        ["bottom"]             = -1000,
        ["below_battlers"]     = -900,
        ["battlers"]           = -850,
        ["above_battlers"]     = -800, --┰-- -800
        ["below_ui"]           = -800, --┙
        ["ui"]                 = -700,
        ["above_ui"]           = -600, --┰-- -600
        ["below_arena"]        = -600, --┙
        ["arena"]              = -500,
        ["above_arena"]        = -400, --┰-- -400
        ["below_bullets"]      = -400, --┙
        ["bullets"]            = -300,
        ["above_bullets"]      = -200, --┰-- -200
        ["below_soul"]         = -200, --┙
        ["soul"]               = -150,
        ["above_soul"]         = -100, --┰-- -100
        ["below_arena_border"] = -100, --┙
        ["arena_border"]       = -50,
        ["above_arena_border"] = 0,
        ["damage_numbers"]     = 150,
        ["top"]                = 1000
    }
end

function lib:onRegistered()
    self.random_encounters = {}
    for _,path,rnd_enc in Registry.iterScripts("battle/randomencounters") do
        assert(rnd_enc ~= nil, '"randomencounters/'..path..'.lua" does not return value')
        rnd_enc.id = rnd_enc.id or path
        self.random_encounters[rnd_enc.id] = rnd_enc
    end
    Kristal.callEvent(MG_EVENT.onRegisterRandomEncounters)

    self.light_encounters = {}
    for _,path,light_enc in Registry.iterScripts("battle/lightencounters") do
        assert(light_enc ~= nil, '"lightencounters/'..path..'.lua" does not return value')
        light_enc.id = light_enc.id or path
        self.light_encounters[light_enc.id] = light_enc
    end
    Kristal.callEvent(MG_EVENT.onRegisterLightEncounters)

    self.light_enemies = {}
    for _,path,light_enemy in Registry.iterScripts("battle/lightenemies") do
        assert(light_enemy ~= nil, '"lightenemies/'..path..'.lua" does not return value')
        light_enemy.id = light_enemy.id or path
        self.light_enemies[light_enemy.id] = light_enemy
    end
    Kristal.callEvent(MG_EVENT.onRegisterLightEnemies)
    
    self.light_waves = {}
    for _,path,light_wave in Registry.iterScripts("battle/lightwaves") do
        assert(light_wave ~= nil, '"lightwaves/'..path..'.lua" does not return value')
        light_wave.id = light_wave.id or path
        self.light_waves[light_wave.id] = light_wave
    end
    Kristal.callEvent(MG_EVENT.onRegisterLightWaves)

    self.light_shops = {}
    for _,path,light_shop in Registry.iterScripts("lightshops") do
        assert(light_shop ~= nil, '"lightshops/'..path..'.lua" does not return value')
        light_shop.id = light_shop.id or path
        self.light_shops[light_shop.id] = light_shop
    end
    Kristal.callEvent(MG_EVENT.onRegisterLightShops)
end

function lib:init()

    print("Loaded Magical Glass: Redux " .. self.info.version .. "!")

    self.encounters_enabled = false
    self.steps_until_encounter = nil
end

function lib:registerRandomEncounter(id, class)
    self.random_encounters[id] = class
end

function lib:getRandomEncounter(id)
    return self.random_encounters[id]
end

function lib:createRandomEncounter(id, ...)
    if self.random_encounters[id] then
        return self.random_encounters[id](...)
    else
        error("Attempt to create non existent random encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightEncounter(id, class)
    self.light_encounters[id] = class
end

function lib:getLightEncounter(id)
    return self.light_encounters[id]
end

function lib:createLightEncounter(id, ...)
    if self.light_encounters[id] then
        return self.light_encounters[id](...)
    else
        error("Attempt to create non existent light encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightEnemy(id, class)
    self.light_enemies[id] = class
end

function lib:getLightEnemy(id)
    return self.light_enemies[id]
end

function lib:createLightEnemy(id, ...)
    if self.light_enemies[id] then
        return self.light_enemies[id](...)
    else
        error("Attempt to create non existent light enemy \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightWave(id, class)
    self.light_waves[id] = class
end

function lib:getLightWave(id)
    return self.light_waves[id]
end

function lib:createLightWave(id, ...)
    if self.light_waves[id] then
        return self.light_waves[id](...)
    else
        error("Attempt to create non existent light wave \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightShop(id, class)
    self.light_shops[id] = class
end

function lib:getLightShop(id)
    return self.light_shops[id]
end

function lib:createLightShop(id, ...)
    if self.light_shops[id] then
        return self.light_shops[id](...)
    else
        error("Attempt to create non existent light shop \"" .. tostring(id) .. "\"")
    end
end

function lib:registerDebugOptions(debug)
    debug.exclusive_battle_menus = {}
    debug.exclusive_battle_menus["LIGHTBATTLE"] = {"light_wave_select"}
    debug.exclusive_battle_menus["DARKBATTLE"] = {"wave_select"}
    debug.exclusive_world_menus = {}
    debug.exclusive_world_menus["LIGHTWORLD"] = {}
    debug.exclusive_world_menus["DARKWORLD"] = {}

    debug:registerMenu("encounter_select", "Encounter Select")
    
    debug:registerOption("encounter_select", "Start Dark Encounter", "Start a dark encounter.", function()
        debug:enterMenu("dark_encounter_select", 0)
    end)
    debug:registerOption("encounter_select", "Start Light Encounter", "Start a light encounter.", function()
        debug:enterMenu("light_encounter_select", 0)
    end)

    debug:registerMenu("dark_encounter_select", "Select Dark Encounter", "search")
    for id,_ in pairs(Registry.encounters) do
        if id ~= "_nobody" or Kristal.getLibConfig("magical-glass", "debug") then
            debug:registerOption("dark_encounter_select", id, "Start this encounter.", function()
                Game:encounter(id, true, nil, nil, false)
                debug:closeMenu()
            end)
        end
    end

    debug:registerMenu("light_encounter_select", "Select Light Encounter", "search")
    for id,_ in pairs(self.light_encounters) do
        if id ~= "_nobody" or Kristal.getLibConfig("magical-glass", "debug") then
            debug:registerOption("light_encounter_select", id, "Start this encounter.", function()
                Game:encounter(id, true, nil, nil, true)
                debug:closeMenu()
            end)
        end
    end

    debug:registerMenu("light_wave_select", "Wave Select", "search")
    
    debug:registerOption("light_wave_select", "[Stop Current Wave]", "Stop the current playing wave.", function ()
        if Game.battle:getState() == "DEFENDING" then
            Game.battle.encounter:onWavesDone()
        end
        debug:closeMenu()
    end)

    local waves_list = {}
    for id,_ in pairs(self.light_waves) do
        if id ~= "_none" and id ~= "_story" or Kristal.getLibConfig("magical-glass", "debug") then
            table.insert(waves_list, id)
        end
    end

    table.sort(waves_list, function(a, b)
        return a < b
    end)

    for _,id in ipairs(waves_list) do
        debug:registerOption("light_wave_select", id, "Start this wave.", function ()
            if Game.battle:getState() == "ACTIONSELECT" then
                Game.battle.debug_wave = true
                Game.battle:setState("ENEMYDIALOGUE", {id})
            end
            debug:closeMenu()
        end)
    end
    
    debug:registerMenu("select_shop", "Enter Shop")
    
    debug:registerOption("select_shop", "Enter Dark Shop", "Enter a dark shop.", function()
        debug:enterMenu("dark_select_shop", 0)
    end)
    debug:registerOption("select_shop", "Enter Light Shop", "Enter a light shop.", function()
        debug:enterMenu("light_select_shop", 0)
    end)
    
    debug:registerMenu("dark_select_shop", "Enter Dark Shop", "search")
    for id,_ in pairs(Registry.shops) do
        debug:registerOption("dark_select_shop", id, "Enter this shop.", function()
            Game:enterShop(id, nil, false)
            debug:closeMenu()
        end)
    end

    debug:registerMenu("light_select_shop", "Enter Light Shop", "search")
    for id,_ in pairs(self.light_shops) do
        debug:registerOption("light_select_shop", id, "Enter this shop.", function()
            Game:enterShop(id, nil, true)
            debug:closeMenu()
        end)
    end
    
    debug:registerMenu("give_item", "Give Item")
    
    debug:registerOption("give_item", "Give Dark Item", "Give a dark item.", function()
        debug:enterMenu("dark_give_item", 0)
    end)
    debug:registerOption("give_item", "Give Light Item", "Give a light item.", function()
        debug:enterMenu("light_give_item", 0)
    end)
    debug:registerOption("give_item", "Give Undertale Item", "Give an Undertale item.", function()
        debug:enterMenu("ut_give_item", 0)
    end)
    
    debug:registerMenu("dark_give_item", "Give Dark Item", "search")
    debug:registerMenu("light_give_item", "Give Light Item", "search")
    debug:registerMenu("ut_give_item", "Give Undertale Item", "search")
    for id, item_data in pairs(Registry.items) do
        local item = item_data()
        local menu
        if Utils.sub(item.id, 1, 10) == "undertale/" then
            menu = "ut_give_item"
        elseif item.light then
            menu = "light_give_item"
        else
            menu = "dark_give_item"
        end
        debug:registerOption(menu, item.name, item.description, function ()
            Game.inventory:tryGiveItem(item_data())
        end)
    end
    
    local in_game = function () return Kristal.getState() == Game end
    local in_overworld = function () return in_game() and Game.state == "OVERWORLD" end
    local in_dark_battle = function () return in_game() and Game.state == "BATTLE" and not Game.battle.light end
    local in_light_battle = function () return in_game() and Game.state == "BATTLE" and Game.battle.light end
    local in_dark_world = function () return in_game() and not Game:isLight() end
    local in_light_world = function () return in_game() and Game:isLight() end
    
    for i = #debug.menus["main"].options, 1, -1 do
        local option = debug.menus["main"].options[i]
        if Utils.containsValue({"Start Wave", "End Battle"}, option.name) then
            table.remove(debug.menus["main"].options, i)
        end
    end
    
    debug:registerOption("main", "Start Wave", "Start a wave.", function ()
        debug:enterMenu("wave_select", 0)
    end, in_dark_battle)

    debug:registerOption("main", "End Battle", "Instantly complete a battle.", function ()
        if Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN"}, Game.battle.state) and Game:isLight() then
            Game.battle:setState("DEFENDINGEND", "NONE")
        end
        Game.battle:setState("VICTORY")
        debug:closeMenu()
    end, in_dark_battle)
                        
    debug:registerOption("main", "Start Wave", "Start a wave.", function ()
        debug:enterMenu("light_wave_select", 0)
    end, in_light_battle)

    debug:registerOption("main", "End Battle", "Instantly complete a battle.", function ()
        Game.battle.forced_victory = true
        if Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN", "ENEMYDIALOGUE"}, Game.battle.state) then
            Game.battle.encounter:onWavesDone()
        end
        Game.battle:setState("VICTORY")
        debug:closeMenu()
    end, in_light_battle)
    
    debug:addToExclusiveMenu("OVERWORLD", {"dark_encounter_select", "light_encounter_select", "dark_select_shop", "light_select_shop"})
    debug:addToExclusiveMenu("BATTLE", "light_wave_select")
end

function lib:setupLightShop(shop)
    local check_shop
    if type(shop) == "string" then
        check_shop =  MagicalGlassLib:getLightShop(shop)
    else
        check_shop = shop
    end
    
    if check_shop:includes(Shop) then
        error("Attempted to use Shop in a LightShop. Convert the shop file to a LightShop")
    end
    
    if Game.shop then
        error("Attempt to enter light shop while already in shop")
    end

    if type(shop) == "string" then
        shop = MagicalGlassLib:createLightShop(shop)
    end

    if shop == nil then
        error("Attempt to enter light shop with nil shop")
    end

    Game.shop = shop
    Game.shop:postInit()
end

function lib:enterLightShop(shop, options)
    -- Add the shop to the stage and enter it.
    if Game.shop then
        Game.shop:leaveImmediate()
    end

    lib:setupLightShop(shop)

    if options then
        Game.shop.leave_options = options
    end

    if Game.world and Game.shop.shop_music then
        Game.world.music:stop()
    end

    Game.state = "SHOP"
    
    lib.in_light_shop = true

    Game.stage:addChild(Game.shop)
    Game.shop:onEnter()
end

function lib:setLightBattleShakingText(v)
    if v == true then
        lib.light_battle_shake_text = 0.501
    elseif v == false then
        lib.light_battle_shake_text = 0
    elseif type(v) == "number" then
        lib.light_battle_shake_text = v
    end
end

function lib:setLightBattleSpareColor(value, color_name)
    if value == "pink" then
        lib.spare_color, lib.spare_color_name = MG_PALETTE["pink_spare"], "PINK"
    elseif type(value) == "table" then
        lib.spare_color, lib.spare_color_name = value, "SPAREABLE"
    else
        for name,color in pairs(COLORS) do
            if value == name then
                lib.spare_color, lib.spare_color_name = color, name:upper()
                break
            end
        end
    end
    if type(color_name) == "string" then
        lib.spare_color_name = color_name:upper()
    end
end

function lib:setCellCallsRearrangement(v)
    lib.rearrange_cell_calls = v
end

function lib:setSeriousMode(v)
    lib.serious_mode = v
end

function lib:onFootstep(char, num)
    if self.encounters_enabled and self.in_encounter_zone and Game.world.player and char:includes(Player) then
        local amount = 1
        if Mod.libs["multiplayer"] then
            local players = #Game.stage:getObjects(Player)
            if players > 1 then
                amount = amount / players / 0.8
            end
        end
        self.steps_until_encounter = self.steps_until_encounter - amount
    end
end

function lib:setLightEXP(exp)
    for _,party in pairs(Game.party_data) do
        party:setLightEXP(exp)
    end
end

function lib:setLightLV(level)
    for _,party in pairs(Game.party_data) do
        party:setLightLV(level)
    end
end

function lib:gameNotOver(x, y)
    Kristal.hideBorder(0)
    
    local reload
    local encounter = Game.battle and Game.battle.encounter and Game.battle.encounter.id
    local shop = Game.shop and Game.shop.id
    if encounter then
        reload = {"BATTLE", encounter}
    elseif shop then
        reload = {"SHOP", shop}
    end

    Game.state = "GAMEOVER"
    if Game.battle   then Game.battle  :remove() end
    if Game.world    then Game.world   :remove() end
    if Game.shop     then Game.shop    :remove() end
    if Game.gameover then Game.gameover:remove() end
    if Game.legend   then Game.legend  :remove() end

    Game.gameover = GameNotOver(x or 0, y or 0, reload)
    Game.stage:addChild(Game.gameover)
end
function lib:postUpdate()
    Game.lw_xp = nil
    for _,party in pairs(Game.party_data) do -- Gets the party with the most Light EXP
        if not Game.lw_xp or party:getLightEXP() > Game.lw_xp then
            Game.lw_xp = party:getLightEXP()
        end
    end
    if Kristal.getLibConfig("magical-glass", "shared_light_exp") then
        for _,party in pairs(Game.party_data) do
            if party:getLightEXP() ~= Game.lw_xp then
                party:setLightEXP(Game.lw_xp)
            end
        end
    end
    if not Game.battle then
        if lib.random_encounter then
            lib:createRandomEncounter(lib.random_encounter):resetSteps(false)
            lib.random_encounter = nil
        end
    end
end

return lib