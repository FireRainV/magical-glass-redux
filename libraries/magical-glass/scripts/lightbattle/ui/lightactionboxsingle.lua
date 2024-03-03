local LightActionBoxSingle, super = Class(Object)

function LightActionBoxSingle:init(x, y, index, battler)
    super.init(self, x, y)

    self.index = index
    self.battler = battler

    self.selected_button = 1
    self.last_button = 1

    self.revert_to = 40

    self.data_offset = 0

    if not Game.battle.encounter.story then
        self:createButtons()
    end
end

function LightActionBoxSingle:getHPGaugeLengthCap()
    return Kristal.getLibConfig("magical-glass", "hp_gauge_length_cap")
end

function LightActionBoxSingle:getButtons(battler) end

function LightActionBoxSingle:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end

    self.buttons = {}

    local btn_types = {"fight", "act", "spell", "item", "mercy"}

    if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
    if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "spell") end

    for lib_id,_ in Kristal.iterLibraries() do
        btn_types = Kristal.libCall(lib_id, "getLightActionButtons", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getLightActionButtons", self.battler, btn_types) or btn_types

    for i,btn in ipairs(btn_types) do
        if type(btn) == "string" then
            local x
            local loc = 2
            if #btn_types <= 4 then
                if #btn_types < 4 then
                    if btn == "fight" then
                        loc = 1
                    elseif btn == "act" or btn == "spell" then
                        loc = 2
                    elseif btn == "item" then
                        loc = 3
                    elseif btn == "mercy" then
                        loc = 4
                    end
                else
                    loc = i
                end
                x = math.floor(67 + ((loc - 1) * 156))
                if loc == 2 then
                    x = x - 3
                elseif loc == 3 then
                    x = x + 1
                end
            else
                x = math.floor(67 + ((i - 1) * 117))
            end
            
            local button = LightActionButton(btn, self.battler, x, 175)
            button.actbox = self
            table.insert(self.buttons, button)
            self:addChild(button)
        else
            btn:setPosition(math.floor(66 + ((i - 1) * 156)) + 0.5, 183)
            btn.battler = self.battler
            btn.actbox = self
            table.insert(self.buttons, btn)
            self:addChild(btn)
        end
    end

    self.selected_button = Utils.clamp(self.selected_button, 1, #self.buttons)

end

function LightActionBoxSingle:snapSoulToButton()
    if self.buttons then
        if self.selected_button < 1 then
            self.selected_button = #self.buttons
        end

        if self.selected_button > #self.buttons then
            self.selected_button = 1
        end

        Game.battle.soul.x = self.buttons[self.selected_button].x - 19
        Game.battle.soul.y = self.buttons[self.selected_button].y + 279
        Game.battle:toggleSoul(true)
    end
end

function LightActionBoxSingle:update()
    if self.buttons then
        for i,button in ipairs(self.buttons) do
            if (Game.battle.current_selecting == 0 and self.index == 1) or (Game.battle.current_selecting == self.index) then
                button.visible = true
            else
                button.visible = false
            end
            if (Game.battle.current_selecting == self.index) then
                button.selectable = true
                button.hovered = (self.selected_button == i)
            else
                button.selectable = false
                button.hovered = false
            end
        end
    end

    super.update(self)

end

function LightActionBoxSingle:select()
    self.buttons[self.selected_button]:select()
    self.last_button = self.selected_button
end

function LightActionBoxSingle:unselect()
    self.buttons[self.selected_button]:unselect()
end

function LightActionBoxSingle:drawStatusStripStory()
    if self.index == 1 then
        local x, y = 180, 130
        local level = Game:isLight() and self.battler.chara:getLightLV() or self.battler.chara:getLevel()

        love.graphics.setFont(Assets.getFont("namelv", 24))
        love.graphics.setColor(COLORS["white"])
        love.graphics.print("LV " .. level, x, y)

        love.graphics.draw(Assets.getTexture("ui/lightbattle/hpname"), x + 74, y + 5)

        local max = self.battler.chara:getStat("health")
        local current = self.battler.chara:getHealth()
        
        local limit = self:getHPGaugeLengthCap()
        if limit == true then
            limit = 99
        end
        local size = max
        if limit and size > limit then
            size = limit
            limit = true
        end

        love.graphics.setColor(COLORS["red"])
        love.graphics.rectangle("fill", x + 110, y, size * 1.25, 21)
        love.graphics.setColor(COLORS["yellow"])
        love.graphics.rectangle("fill", x + 110, y, limit == true and math.ceil((math.max(0,current) / max) * size) * 1.25 or math.max(0,current) * 1.25, 21)

        if max < 10 and max >= 0 then
            max = "0" .. tostring(max)
        end

        if current < 10 and current >= 0 then
            current = "0" .. tostring(current)
        end

        local color = COLORS.white
        if self.battler.chara:getHealth() > 0 then
            if self.battler.sleeping then
                color = {0,0,1}
            elseif Game.battle:getActionBy(self.battler) and Game.battle:getActionBy(self.battler).action == "DEFEND" and not Game.battle.forced_victory then
                color = COLORS.aqua
            end
        end
        love.graphics.setColor(color)
        love.graphics.print(current .. " / " .. max, x + 115 + size * 1.25 + 14, y)
    end
end

function LightActionBoxSingle:drawStatusStrip()
    local name = self.battler.chara:getName()
    local level = Game:isLight() and self.battler.chara:getLightLV() or self.battler.chara:getLevel()
    
    local max = self.battler.chara:getStat("health")
    local current = self.battler.chara:getHealth()
    
    if #Game.battle.party == 1 then
        local x, y = 10, 130

        love.graphics.setFont(Assets.getFont("namelv", 24))
        love.graphics.setColor(COLORS["white"])
        love.graphics.print(name .. "   LV " .. level, x, y)

        love.graphics.draw(Assets.getTexture("ui/lightbattle/hpname"), x + 214, y + 5)
        
        local limit = self:getHPGaugeLengthCap()
        if limit == true then
            limit = 99
        end
        local size = max
        if limit and size > limit then
            size = limit
            limit = true
        end

        love.graphics.setColor(COLORS["red"])
        love.graphics.rectangle("fill", x + 245, y, size * 1.25, 21)
        love.graphics.setColor(COLORS["yellow"])
        love.graphics.rectangle("fill", x + 245, y, limit == true and math.ceil((math.max(0,current) / max) * size) * 1.25 or math.max(0,current) * 1.25, 21)

        if max < 10 and max >= 0 then
            max = "0" .. tostring(max)
        end

        if current < 10 and current >= 0 then
            current = "0" .. tostring(current)
        end

        local color = COLORS.white
        if self.battler.chara:getHealth() > 0 then
            if self.battler.sleeping then
                color = {0,0,1}
            elseif Game.battle:getActionBy(self.battler) and Game.battle:getActionBy(self.battler).action == "DEFEND" and not Game.battle.forced_victory then
                color = COLORS.aqua
            end
        end
        love.graphics.setColor(color)
        love.graphics.print(current .. " / " .. max, x + 245 + size * 1.25 + 14, y)
    else
        local x, y = 10 + (3 - #Game.battle.party) * 198 / 2 + (Utils.getIndex(Game.battle.party, self.battler) - 1) * 198, 130
        
        love.graphics.setFont(Assets.getFont("namelv", 24))
        love.graphics.setColor(COLORS["white"])
        love.graphics.print(name, x, y - 7)
        love.graphics.setFont(Assets.getFont("namelv", 16))
        love.graphics.print("LV " .. level, x, y + 13)
        
        love.graphics.draw(Assets.getTexture("ui/lightbattle/hpname"), x + 64, y + 15)
        
        love.graphics.setColor(COLORS["red"])
        love.graphics.rectangle("fill", x + 92, y, 32 * 1.25, 21)
        love.graphics.setColor(COLORS["yellow"])
        love.graphics.rectangle("fill", x + 92, y, math.ceil((Utils.clamp(current, 0, max) / max) * 32) * 1.25, 21)
        
        love.graphics.setFont(Assets.getFont("namelv", 16))
        if max < 10 and max >= 0 then
            max = "0" .. tostring(max)
        end

        if current < 10 and current >= 0 then
            current = "0" .. tostring(current)
        end

        
        local color = COLORS.white
        if self.battler.is_down then 
            color = {1,0,0}
        elseif self.battler.sleeping then
            color = {0,0,1}
        elseif Game.battle:getActionBy(self.battler) and Game.battle:getActionBy(self.battler).action == "DEFEND" and not Game.battle.forced_victory then
            color = COLORS.aqua
        end
        love.graphics.setColor(color)
        love.graphics.print(current .. "/" .. max, x + 137, y + 3)
        
        if Game.battle.current_selecting == self.index then
            love.graphics.setColor(self.battler.chara:getLightColor())
            love.graphics.setLineWidth(2)
            love.graphics.line(x - 3, y - 7, x - 3, y + 28)
            love.graphics.line(x - 3 - 1, y - 7, x + 188 + 1, y - 7)
            love.graphics.line(x + 188, y - 7, x + 188, y + 28)
            love.graphics.line(x - 3 - 1, y + 28, x + 188 + 1, y + 28)
        end
    end
end

function LightActionBoxSingle:draw()

    if Game.battle.encounter.story then
        self:drawStatusStripStory()
    else
        self:drawStatusStrip()
    end

    super.draw(self)

end

return LightActionBoxSingle