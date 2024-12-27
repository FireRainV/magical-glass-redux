local Dummy, super = Class(LightEnemyBattler)

function Dummy:init()
    super:init(self)

    -- Enemy name
    self.name = "Dummy"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("dummy_ut")

    -- Enemy health
    self.max_health = 5000
    self.health = 5000
    -- Enemy attack (determines bullet damage)
    self.attack = 5
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 0
    self.experience = 0
    
    -- self.spare_points = 1
    
    self.dialogue_bubble = "ut_large"

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        -- "basic",
        -- "aiming",
        -- "movingarena"
    }

    self.menu_waves = {
        -- "aiming"
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "[wave:3][speed:0.5]....."
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "ATK 5 DEF 0\n* Cotton heart and button eye\n* You are the apple of my eye"

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* Dummy stands around\nabsentmindedly.",
        "* Dummy stands around\nabsentmindedly?"
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* The dummy looks like it's\nabout to fall over."

    -- Register act called "Smile"
    self:registerAct("Smile")
    self:registerAct("Attack")
    self:registerAct("lmao", "", "all")
    
    -- Register party act with Noelle called "Tell Story"
    -- (second argument is description, usually empty)
    self:registerAct("Tell Story", "", {"noelle"})
    
    self:registerAct("Wave Mode", "", "all")
    
    self:registerAct("Red Buster", "Red\nDamage", "susie", 60)
    self:registerAct("DualHeal", "Heals\neveryone", "noelle", 50)

    -- can be a table or a number. if it's a number, it determines the width, and the height will be 13 (the ut default).
    -- if it's a table, the first value is the width, and the second is the height
    self.gauge_size = 150

    self.damage_offset = {5, -70}
end

function Dummy:onDodge(battler, attacked)
    print("Missed!", battler.chara.id, attacked)
end

function Dummy:onAct(battler, name)
    if name == "DualHeal" then
        Game.battle:powerAct("dual_heal", battler, "noelle")
    elseif name == "Red Buster" then
        Game.battle:powerAct("red_buster", battler, "susie", self)
    elseif name == "Smile" then
        -- Give the enemy 100% mercy
        self:addMercy(100)
        -- Change this enemy's dialogue for 1 turn
        self.dialogue_override = "[wave:3][speed:0.5]... ^^"
        -- Act text (since it's a list, multiple textboxes)
        return {
            "* You smile.[wait:5]\n* The dummy smiles back.",
            "* It seems the dummy just wanted\nto see you happy."
        }

    elseif name == "Tell Story" then
        -- Loop through all enemies
        for _,enemy in ipairs(Game.battle.enemies) do
            -- Make the enemy tired
            enemy:setTired(true)
        end
        return "* You and Noelle told the dummy\na bedtime story.\n* The enemies became [color:blue]TIRED[color:reset]..."

    elseif name == "Attack" then
        self.wave_override = Utils.pick({"basic", "aiming", "movingarena"})
        return "* ok"

    elseif name == "lmao" then
        self.menu_wave_override = "aiming"
        return "* get attacked"
        
    elseif name == "Wave Mode" then
        if self.encounter.wave_mode then
            self.encounter.wave_mode = false
            self.waves = {}
            return "* Normal Mode."
        else
            self.encounter.wave_mode = true
            self.waves = {
                "basic",
                "aiming",
                "movingarena"
            }
            return "* Wave Mode!"
        end

    elseif name == "Standard" then --X-Action
        -- Give the enemy 50% mercy
        self:addMercy(50)
        if battler.chara.id == "ralsei" then
            -- R-Action text
            return "* Ralsei bowed politely.\n* The dummy spiritually bowed\nin return."
        elseif battler.chara.id == "susie" then
            -- S-Action: start a cutscene (see scripts/battle/cutscenes/dummy.lua)
            Game.battle:startActCutscene("dummy", "susie_punch")
            return
        else
            -- Text for any other character (like Noelle)
            return "* "..battler.chara:getName().." straightened the\ndummy's hat."
        end
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super:onAct(self, battler, name)
end

return Dummy