return {
    box_a = function(cutscene)
        Assets.stopAndPlaySound("dimbox")
        Game.world.timer:after(5/30, function() -- todo: this doesn't lock your movement????
            Game.world:openMenu(LightStorageMenu("items", "box_a"))
        end)
    end,
    box_b = function(cutscene)
        Assets.stopAndPlaySound("dimbox")
        Game.world.timer:after(5/30, function()
            Game.world:openMenu(LightStorageMenu("items", "box_b"))
        end)
    end
}