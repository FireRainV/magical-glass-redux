return {
    image = function (cutscene)
        cutscene:text("* Kris check it out [image:party/susie/dark/t_pose]\n[wait:5]* I'm in the textbox",
                      "surprise_smile", "susie")
        cutscene:text("* Get out of there!!!", "angrier", "ralsei")
        cutscene:text("* [wait:10][image:party/susie/dark/fell]", "smile", "susie")
        cutscene:text(
            "* Susie if you don't get out of the textbox in 5 seconds,[wait:5] then I will be forced to come in there and get you.",
            "angry", "ralsei")
        cutscene:text("* Sorry can't hear you,[wait:5] you ran out of textbox space[image:party/susie/dark/away_hand]",
                      "smile", "susie")
        cutscene:text("* I said I will come and get you out of there", "angry", "ralsei")
        cutscene:text("* Try it [image:party/susie/dark/walk_back_arm/left_1]", "smile", "susie")
        cutscene:text("* That's it!", "angry", "ralsei")
        cutscene:text("* hoooOOOOOOOOOOOOOOOOOOO\nOOAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", "angry", "ralsei", { auto = true })
        cutscene:text("[image:party/ralsei/dark/walk/down_1]", nil, "ralsei")
        cutscene:text("* You know what,[wait:5] this isn't that bad [image:party/ralsei/dark/walk/down_1]", "neutral",
                      "ralsei")
        local susie_sprite = nil
        local ralsei_sprite = nil
        cutscene:text(
            "* [image:party/susie/dark/walk/down_1, 0, 0, 2, 2][image:party/ralsei/dark/walk/down_1, 0, 0, 2, 2] Atta boy[func:grabloc]",
            "smile", "susie", {
                functions = {
                    grabloc = function (text)
                        local sprites = text.sprites
                        susie_sprite = Sprite("party/susie/dark/walk/down_1", sprites[1]:getScreenPos())
                        susie_sprite:setOrigin(0, 0.5)
                        susie_sprite:setScale(2, 2)
                        ralsei_sprite = Sprite("party/ralsei/dark/walk/down_1", sprites[2]:getScreenPos())
                        ralsei_sprite:setOrigin(0, 0.5)
                        ralsei_sprite:setScale(2, 2)
                        susie_sprite.layer = WORLD_LAYERS["textbox"] + 100
                        ralsei_sprite.layer = WORLD_LAYERS["textbox"] + 100
                        susie_sprite:setParallax(0, 0)
                        ralsei_sprite:setParallax(0, 0)
                        susie_sprite.visible = false
                        ralsei_sprite.visible = false
                        Game.world:addChild(susie_sprite)
                        Game.world:addChild(ralsei_sprite)
                    end
                }
            })
        susie_sprite.visible = true
        ralsei_sprite.visible = true
        local wait, textbox = cutscene:text("", nil, nil, { advance = false })
        susie_sprite.x = susie_sprite.x + susie_sprite.width
        susie_sprite:setSprite("party/susie/dark/playful_punch_1")
        susie_sprite.x = susie_sprite.x + susie_sprite.width
        susie_sprite:setScale(-2, 2)
        cutscene:wait(0.5)
        susie_sprite:setSprite("party/susie/dark/playful_punch_2")
        Assets.playSound("impact")
        ralsei_sprite:setSprite("party/ralsei/dark/splat")
        ralsei_sprite.physics.direction = math.rad(10)
        ralsei_sprite.physics.speed = 24
        ralsei_sprite.physics.friction = 1.5
        cutscene:wait(0.5)
        local explosion = ralsei_sprite:explode(0, 0, true)
        explosion:setScale(3, 3)
        cutscene:wait(0.2)
        ralsei_sprite:remove()
        cutscene:wait(3)
        textbox:setText("[voice:susie]* Whoops", nil, "susie")
        textbox:setAdvance(true)
        cutscene:wait(wait)
        susie_sprite:remove()
    end,
    
    shop = function (cutscene)
        local candy = Registry.createItem("ut_items/monster_candy")
        cutscene:showShop()
        cutscene:text("* Hello![wait:5] It's a me Super Mario on the PS4.[wait:5] Whohooo!")
        cutscene:text(string.format("* I got some spare candies to sell.\nThey're %dG,[wait:5] interested?", 10))

        local buying = cutscene:textChoicer("* Buy the Monster Candy for 10G?", {"Yes", "No"}) == 1
        if not buying then
            cutscene:text("* Mamma mia...")
        elseif Game.lw_money < 10 then
            cutscene:text("* Oh no...[wait:5] You don't have the money...")
        else
            local success, result_text = Game.inventory:tryGiveItem(candy)
            if success then
                Game.lw_money = Game.lw_money - 10
                cutscene:text("* Whohooo![wait:5] Here's your candy.\n"..result_text)
            else
                cutscene:text("* Oh no...[wait:5] no space...\n"..result_text)
            end
        end
        cutscene:hideShop()
    end,
}
