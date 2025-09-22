local actor, super = Class(Actor, "kris_ut")

function actor:init()
    super.init(self)

    -- Display name (optional)
    self.name = "Kris"

    -- Width and height for this actor, used to determine its center
    self.width = 20
    self.height = 30
    
    self.use_light_battler_sprite = true

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {0, 25, 19, 14}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 0, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "enemies/kris_ut"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "full_body"

    -- Sound to play when this actor speaks (optional)
    self.voice = nil
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {}

    self.light_battle_width = 41
    self.light_battle_height = 92
    
    self:addLightBattlerPart("head", {
        -- path, function that returns a path, or a function that returns a sprite object
        -- if one's not defined, get the default animation
        ["create_sprite"] = function()
            local sprite = Sprite(self.path.."/head")
            sprite.layer = 500
            local path =    {{0, 0}, {-1, 1}, {-1, 2}, {-1, 3}, {0, 1}, {1, 3}, {1, 2}, {1, 1}, {0, 0}}
            sprite:slidePath(path, {speed = 0.2, loop = true, relative = true})
            return sprite
        end,
    })

    self:addLightBattlerPart("body", {
        -- path, function that returns a path, or a function that returns a sprite object
        -- if one's not defined, get the default animation
        ["create_sprite"] = function()
            local sprite = Sprite(self.path.."/body", 0, 34)
            sprite.layer = 499
            local path =    {{0, 0}, {-1, -1}, {-1, 0}, {-1, 1}, {0, 0}, {1, 1}, {1, 0}, {1, -1}, {0, 0}}
            sprite:slidePath(path, {speed = 0.2, loop = true, relative = true})
            return sprite
        end
    })
    
    self:addLightBattlerPart("legs", {
        -- path, function that returns a path, or a function that returns a sprite object
        -- if one's not defined, get the default animation
        ["create_sprite"] = function()
            local sprite = Sprite(self.path.."/legs", 2, 59)
            sprite.layer = 498
            return sprite
        end
    })

end

return actor