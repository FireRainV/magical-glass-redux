---@class LightItemMenu : LightItemMenu
local LightItemMenu, super = Utils.hookScript(LightItemMenu)

function LightItemMenu:draw()
    if TARGET_MOD == "dpr_main" then super.draw(self) return end
    
    love.graphics.setFont(self.font)
    local inventory = Game.inventory:getStorage(self.storage)
    for index, item in ipairs(inventory) do
        if (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
            Draw.setColor(PALETTE["world_text"])
        else
            Draw.setColor(PALETTE["world_text_unusable"])
        end
        if self.state == "PARTYSELECT" then
            local function party_box_area()
                local party_box = self.party_select_bg
                love.graphics.rectangle("fill", party_box.x - 24, party_box.y - 24, party_box.width + 48, party_box.height + 48)
            end
            love.graphics.stencil(party_box_area, "replace", 1)
            love.graphics.setStencilTest("equal", 0)
        end
        love.graphics.print(item:getName(), 20, -28 + (index * 32))
        love.graphics.setStencilTest()
    end
    if self.state ~= "PARTYSELECT" then
        local item = Game.inventory:getItem(self.storage, self.item_selecting)
        if (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
            Draw.setColor(PALETTE["world_text"])
        else
            Draw.setColor(PALETTE["world_gray"])
        end
        love.graphics.print("USE" , 20 , 284)
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print("INFO", 116, 284)
        love.graphics.print("DROP", 230, 284)
    end
    Draw.setColor(Game:getSoulColor())
    if self.state == "ITEMSELECT" then
        Draw.draw(self.heart_sprite, -4, -20 + (32 * self.item_selecting), 0, 2, 2)
    elseif self.state == "ITEMOPTION" then
        if self.option_selecting == 1 then
            Draw.draw(self.heart_sprite, -4, 292, 0, 2, 2)
        elseif self.option_selecting == 2 then
            Draw.draw(self.heart_sprite, 92, 292, 0, 2, 2)
        elseif self.option_selecting == 3 then
            Draw.draw(self.heart_sprite, 206, 292, 0, 2, 2)
        end
    elseif self.state == "PARTYSELECT" then
        local item = Game.inventory:getItem(self.storage, self.item_selecting)
        Draw.setColor(PALETTE["world_text"])
        
        local z = Mod.libs["moreparty"] and Kristal.getLibConfig("moreparty", "classic_mode") and 3 or 4
        
        Draw.printAlign("Use " .. item:getName() .. " on", 150, 231, "center")
        for i,party in ipairs(Game.party) do
            if i <= z then
                love.graphics.print(party:getShortName(), 63 - (math.min(#Game.party,z) - 2) * 70 + (i - 1) * 122, 269)
            else
                love.graphics.print(party:getShortName(), 63 - (math.min(#Game.party - z,z) - 2) * 70 + (i - 1 - z) * 122, 269 + 38)
            end
        end
        Draw.setColor(Game:getSoulColor())
        for i,party in ipairs(Game.party) do
            if i == self.party_selecting then
                if i <= z then
                    Draw.draw(self.heart_sprite, 39 - (math.min(#Game.party,z) - 2) * 70 + (i - 1) * 122, 277, 0, 2, 2)
                else
                    Draw.draw(self.heart_sprite, 39 - (math.min(#Game.party - z,z) - 2) * 70 + (i - 1 - z) * 122, 277 + 38, 0, 2, 2)
                end
            end
        end
    end
    Object.draw(self)
end

function LightItemMenu:useItem(item)
    if TARGET_MOD == "dpr_main" then super.useItem(self, item) return end
    
    local result
    if item.target == "ally" then
        result = item:onWorldUse(Game.party[self.party_selecting])
    else
        result = item:onWorldUse(Game.party)
    end
    
    if result then
        if item:hasResultItem() then
            Game.inventory:replaceItem(item, item:createResultItem())
        else
            Game.inventory:removeItem(item)
        end
    end
end

function LightItemMenu:init()
    super.init(self)
    if TARGET_MOD == "dpr_main" then return end
    if Mod.libs["moreparty"] and #Game.party > 3 then
        if not Kristal.getLibConfig("moreparty", "classic_mode") then
            self.party_select_bg = UIBox(-97, 242, 492, #Game.party == 4 and 52 or 90)
        else
            self.party_select_bg = UIBox(-37, 242, 372, 90)
        end
    else
        self.party_select_bg = UIBox(-37, 242, 372, 52)
    end
    self.party_select_bg.visible = false
    self.party_select_bg.layer = -1
    self.party_selecting = 1
    self:addChild(self.party_select_bg)
end

function LightItemMenu:update()
    if TARGET_MOD == "dpr_main" then super.update(self) return end
    
    if self.state == "ITEMOPTION" then
        if Input.pressed("cancel") then
            self.state = "ITEMSELECT"
            return
        end
        local old_selecting = self.option_selecting
        if Input.pressed("left") then
            self.option_selecting = self.option_selecting - 1
        end
        if Input.pressed("right") then
            self.option_selecting = self.option_selecting + 1
        end
        self.option_selecting = Utils.clamp(self.option_selecting, 1, 3)
        if self.option_selecting ~= old_selecting then
            self.ui_move:stop()
            self.ui_move:play()
        end
        if Input.pressed("confirm") then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            if self.option_selecting == 1 and (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
                self.party_selecting = 1
                if #Game.party > 1 and item.target == "ally" then
                    self.ui_select:stop()
                    self.ui_select:play()
                    self.party_select_bg.visible = true
                    self.state = "PARTYSELECT"
                else
                    self:useItem(item)
                end
            elseif self.option_selecting == 2 then
                item:onCheck()
            elseif self.option_selecting == 3 then
                self:dropItem(item)
            end
        end
    elseif self.state == "PARTYSELECT" then
        if Input.pressed("cancel") then
            self.party_select_bg.visible = false
            self.state = "ITEMOPTION"
            return
        end
        local old_selecting = self.party_selecting
        if Input.pressed("right") then
            self.party_selecting = self.party_selecting + 1
        end
        if Input.pressed("left") then
            self.party_selecting = self.party_selecting - 1
        end
        self.party_selecting = Utils.clamp(self.party_selecting, 1, #Game.party)
        if self.party_selecting ~= old_selecting then
            self.ui_move:stop()
            self.ui_move:play()
        end
        if Input.pressed("confirm") then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            self:useItem(item)
        end
    else
        super.update(self)
    end
end

return LightItemMenu
