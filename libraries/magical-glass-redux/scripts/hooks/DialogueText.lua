---@class DialogueText : DialogueText
local DialogueText, super = Utils.hookScript(DialogueText)

function DialogueText:resetState()
    Text.resetState(self)
    self.state["typing_sound"] = self.default_sound
end

function DialogueText:playTextSound(current_node)
    if self.state.skipping and (Input.down("cancel") and Kristal.getLibConfig("magical-glass", "undertale_text_skipping") ~= true or self.played_first_sound) then
        return
    end
    if current_node.type ~= "character" then
        return
    end
    local no_sound = { "\n", " ", "^", "!", ".", "?", ",", ":", "/", "\\", "|", "*" }
    if (Utils.containsValue(no_sound, current_node.character)) then
        return
    end
    if (self.state.typing_sound ~= nil) and (self.state.typing_sound ~= "") then
        self.played_first_sound = true
        if Kristal.callEvent(KRISTAL_EVENT.onTextSound, self.state.typing_sound, current_node, self.state) then
            return
        end
        if self:getActor()
            and (self:getActor():getVoice() or "default") == self.state.typing_sound
            and self:getActor():onTextSound(current_node, self.state) then
            return
        end
        
        if not self.no_sound_overlap then
            Assets.playSound("voice/" .. self.state.typing_sound)
        else
            Assets.stopAndPlaySound("voice/" .. self.state.typing_sound)
        end
    end
end

function DialogueText:init(text, x, y, w, h, options)
    options = options or {}
    self.default_sound = options["default_sound"] or "default"
    self.no_sound_overlap = options["no_sound_overlap"] or false
    if options["no_sound_overlap"] == nil and Game.battle and Game.battle.light then
        self.no_sound_overlap = true
    end
    super.init(self, text, x, y, w, h, options)
end

function DialogueText:update()
    local speed = self.state.speed
    if not OVERLAY_OPEN then
        if Kristal.getLibConfig("magical-glass", "undertale_text_skipping") == true then
            local input = self.can_advance and Input.pressed("confirm")
            if input or self.auto_advance or self.should_advance then
                self.should_advance = false
                if not self.state.typing then
                    self:advance()
                end
            end
            
            self.fast_skipping_timer = 0
    
            if self.skippable and not self.state.noskip then
                if not self.skip_speed then
                    if Input.pressed("cancel") then
                        self.state.skipping = true
                    end
                else
                    if Input.down("cancel") then
                        speed = speed * 2
                    end
                end
            end
        else
            if Input.pressed("menu") then
                self.fast_skipping_timer = 1
            end
            local input = self.can_advance and
                (Input.pressed("confirm") or (Input.down("menu") and self.fast_skipping_timer >= 1))
            if input or self.auto_advance or self.should_advance then
                self.should_advance = false
                if not self.state.typing then
                    self:advance()
                end
            end
            if Input.down("menu") then
                if self.fast_skipping_timer < 1 then
                    self.fast_skipping_timer = self.fast_skipping_timer + DTMULT
                end
            else
                self.fast_skipping_timer = 0
            end
            if self.skippable and ((Input.down("cancel") and not self.state.noskip) or (Input.down("menu") and not self.state.noskip)) then
                if not self.skip_speed then
                    self.state.skipping = true
                else
                    speed = speed * 2
                end
            end
        end
    end
    if self.state.waiting == 0 then
        self.state.progress = self.state.progress + (DT * 30 * speed)
    else
        self.state.waiting = math.max(0, self.state.waiting - DT)
    end
    if self.state.typing then
        self:drawToCanvas(function ()
            while (math.floor(self.state.progress) > self.state.typed_characters) or self.state.skipping do
                local current_node = self.nodes[self.state.current_node]
                if current_node == nil then
                    self.state.typing = false
                    break
                end
                self:playTextSound(current_node)
                self:processNode(current_node, false)
                if self.state.skipping then
                    self.state.progress = self.state.typed_characters
                end
                self.state.current_node = self.state.current_node + 1
            end
        end)
    end
    self:updateTalkSprite(self.state.talk_anim and self.state.typing)
    Text.update(self)
    self.last_talking = self.state.talk_anim and self.state.typing
end

return DialogueText
