---@class Battle : Battle
local Battle, super = Utils.hookScript(Battle)

function Battle:returnToWorld()
    super.returnToWorld(self)
    MagicalGlassLib.current_battle_system = nil
end

function Battle:drawBackground()
    if Game:isLight() then
        Draw.setColor(0, 0, 0, self.transition_timer / 10)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)
        love.graphics.setLineStyle("rough")
        love.graphics.setLineWidth(1)
        for i = 2, 16 do
            Draw.setColor(0, 61 / 255, 17 / 255, (self.transition_timer / 10) / 2)
            love.graphics.line(0, -210 + (i * 50) + math.floor(self.offset / 2), 640, -210 + (i * 50) + math.floor(self.offset / 2))
            love.graphics.line(-200 + (i * 50) + math.floor(self.offset / 2), 0, -200 + (i * 50) + math.floor(self.offset / 2), 480)
        end
        for i = 3, 16 do
            Draw.setColor(0, 61 / 255, 17 / 255, self.transition_timer / 10)
            love.graphics.line(0, -100 + (i * 50) - math.floor(self.offset), 640, -100 + (i * 50) - math.floor(self.offset))
            love.graphics.line(-100 + (i * 50) - math.floor(self.offset), 0, -100 + (i * 50) - math.floor(self.offset), 480)
        end
    else
        super.drawBackground(self)
    end
end

function Battle:setWaves(waves, allow_duplicates)
    for i,wave in ipairs(waves) do
        if type(wave) == "string" then
            wave = Registry.getWave(wave)
        end
        if wave:includes(LightWave) then
            error("Attempted to use LightWave in a DarkBattle. Convert '"..waves[i].."' to a Wave")
        end
    end
    return super.setWaves(self, waves, allow_duplicates)
end

function Battle:onKeyPressed(key)
    if Kristal.Config["debug"] and Input.ctrl() then
        if key == "y" and Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN"}, self.state) and Game:isLight() then
            Game.battle:setState("DEFENDINGEND", "NONE")
        end
    end
    super.onKeyPressed(self, key)
end

function Battle:onStateChange(old, new)
    local result = self.encounter:beforeStateChange(old,new)
    if result or self.state ~= new then
        return
    end
    if new == "VICTORY" and Game:isLight() then
        self.current_selecting = 0
        if self.tension_bar then
            self.tension_bar:hide()
        end
        for _,battler in ipairs(self.party) do
            battler:setSleeping(false)
            battler.defending = false
            battler.action = nil
            battler.chara:resetBuffs()
            if battler.chara:getHealth() <= 0 then
                battler:revive()
                battler.chara:setHealth(battler.chara:autoHealAmount())
            end
            battler:setAnimation("battle/victory")
            local box = self.battle_ui.action_boxes[self:getPartyIndex(battler.chara.id)]
            box:resetHeadIcon()
        end
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_tension") then
            self.money = self.money + math.floor(Game:getTension() / 5)
        end
        for _,battler in ipairs(self.party) do
            for _,equipment in ipairs(battler.chara:getEquipment()) do
                self.money = math.floor(equipment:applyMoneyBonus(self.money) or self.money)
            end
        end
        self.money = math.floor(self.money)
        self.money = self.encounter:getVictoryMoney(self.money) or self.money
        self.xp = self.encounter:getVictoryXP(self.xp) or self.xp
        -- if (in_dojo) then
        --     self.money = 0
        -- end
        Game.lw_money = Game.lw_money + self.money
        if (Game.lw_money < 0) then
            Game.lw_money = 0
        end
        local win_text = "* You won!\n* Got " .. self.xp .. " EXP and " .. self.money .. " "..Game:getConfig("lightCurrency"):lower().."."
        -- if (in_dojo) then
        --     win_text == "* You won the battle!"
        -- end
        
        for _,member in ipairs(self.party) do
            local lv = member.chara:getLightLV()
            member.chara:addLightEXP(self.xp)
            if lv ~= member.chara:getLightLV() then
                win_text = "* You won!\n* Got " .. self.xp .. " EXP and " .. self.money .. " "..Game:getConfig("lightCurrency"):lower()..".\n* Your "..Kristal.getLibConfig("magical-glass", "light_level_name").." increased."
                Assets.stopAndPlaySound("levelup")
            end
        end
        win_text = self.encounter:getVictoryText(win_text, self.money, self.xp) or win_text
        if self.encounter.no_end_message then
            self:setState("TRANSITIONOUT")
            self.encounter:onBattleEnd()
        else
            self:battleText(win_text, function()
                self:setState("TRANSITIONOUT")
                self.encounter:onBattleEnd()
                return true
            end)
        end
    else
        super.onStateChange(self, old, new)
    end
end

function Battle:nextTurn()
    self.turn_count = self.turn_count + 1
    if self.turn_count > 1 then
        for _,battler in ipairs(self.party) do
            if battler.chara:onTurnEnd(battler) then
                return
            end
        end
    end
    self.turn_count = self.turn_count - 1
    return super.nextTurn(self)
end

function Battle:init()
    super.init(self)
    self.light = false
    self.soul_speed_bonus = 0
end

function Battle:postInit(state, encounter)
    local check_encounter
    if type(encounter) == "string" then
        check_encounter = Registry.getEncounter(encounter)
    else
        check_encounter = encounter
    end
    
    if check_encounter:includes(LightEncounter) then
        error("Attempted to use LightEncounter in a DarkBattle. Convert the encounter file to an Encounter")
    end
    super.postInit(self, state, encounter)
    if not Kristal.getLibConfig("magical-glass", "light_world_dark_battle_tension") and Game:isLight() then
        self.tension_bar:remove()
        self.tension_bar = nil
    end
end

return Battle
