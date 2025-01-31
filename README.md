# Spring-25-The-Nutty-Arcade-Gamifying-Squirrel-Census-Data

The Nutty Arcade: Gamifying Squirrel Census Data

NYC Open Data Week 2025 Workshop

Presented by **Kiley Matschke** (Post-Baccalaureate Fellow, Barnard College Vagelos Computational Science Center)

### **Dataset:** [Squirrel Census Data](https://www.dropbox.com/scl/fi/is2yaa5gz1of32xo1xwvd/squirrel-data.csv?rlkey=sao5wj2tqd98nzs6rsi5k7ot6&e=2&dl=0)


### **Graphics, Font & Soundtrack**

1. [Sprite Lands Asset Pack](https://cupnooble.itch.io/sprout-lands-asset-pack)
2. [SunnyLand Woods Asset Pack](https://ansimuz.itch.io/sunnyland-woods)
3. [Itch.io](http://Itch.io)
4. [Figma](http://figma.com)
5. [Dafont](https://www.dafont.com/)
6. [Cozy Animal Crossing Music](https://youtu.be/8kBlKM71pjc?si=20Xfh4WgZb2Sj34r)


### **Environment Setup**

1. [Download Visual Studio Code](https://code.visualstudio.com/Download)
2. [Download LÖVE](https://love2d.org/)


## **Code**

### **Project hierarchy**

**Parent folder: squirrels**

| Sub-folders       | Contents           |
| :-------------: |:-------------:| 
| fonts         | hipchick.ttf |
| sounds        | animalcrossing.wav      |  
| graphics | all-squirrels.png, character.png, tileset2.png, tree.png  |   
| lib            | Animation.lua, class.lua, push.lua, StateMachine.lua, Util.lua    |    
| src            | Area.lua, constants.lua, dependencies.lua, entity_defs.lua, Player.lua, PlayState.lua, squirrel-data.csv, Squirrel.lua | 
| main.lua (file)        |    


## **lib (folder)**


<details>
  <summary><h3><b>Animation.lua</b></h3></summary>
  
  ```lua
    Animation = Class{}
    
    function Animation:init(def)
        self.frames = def.frames
        self.interval = def.interval
        self.texture = def.texture
        self.currentFrame = 1
        self.elapsedTime = 0
    end
    
    function Animation:update(dt)
        self.elapsedTime = self.elapsedTime + dt
    
        -- advance frame if time passed exceeds the set interval
        if self.elapsedTime >= self.interval then
            self.currentFrame = (self.currentFrame % #self.frames) + 1
            self.elapsedTime = self.elapsedTime - self.interval
        end
    end
    
    function Animation:render(x, y)
        local frame = self.frames[self.currentFrame]
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][frame], x, y)
    end

  ```
</details>













<details>
  <summary><h3><b>class.lua</b></h3></summary>
  
  ```lua
    local function include_helper(to, from, seen)
    	if from == nil then
    		return to
    	elseif type(from) ~= 'table' then
    		return from
    	elseif seen[from] then
    		return seen[from]
    	end
    
    	seen[from] = to
    	for k,v in pairs(from) do
    		k = include_helper({}, k, seen) -- keys might also be tables
    		if to[k] == nil then
    			to[k] = include_helper({}, v, seen)
    		end
    	end
    	return to
    end
    
    -- deeply copies `other' into `class'. keys in `other' that are already
    -- defined in `class' are omitted
    local function include(class, other)
    	return include_helper(class, other, {})
    end
    
    -- returns a deep copy of `other'
    local function clone(other)
    	return setmetatable(include({}, other), getmetatable(other))
    end
    
    local function new(class)
    	-- mixins
    	class = class or {}  -- class can be nil
    	local inc = class.__includes or {}
    	if getmetatable(inc) then inc = {inc} end
    
    	for _, other in ipairs(inc) do
    		if type(other) == "string" then
    			other = _G[other]
    		end
    		include(class, other)
    	end
    
    	-- class implementation
    	class.__index = class
    	class.init    = class.init    or class[1] or function() end
    	class.include = class.include or include
    	class.clone   = class.clone   or clone
    
    	-- constructor call
    	return setmetatable(class, {__call = function(c, ...)
    		local o = setmetatable({}, c)
    		o:init(...)
    		return o
    	end})
    end
    
    -- interface for cross class-system compatibility (see https://github.com/bartbes/Class-Commons).
    if class_commons ~= false and not common then
    	common = {}
    	function common.class(name, prototype, parent)
    		return new{__includes = {prototype, parent}}
    	end
    	function common.instance(class, ...)
    		return class(...)
    	end
    end
    
    
    -- the module
    return setmetatable({new = new, include = include, clone = clone},
    	{__call = function(_,...) return new(...) end})

  ```
</details>











<details>
  <summary><h3><b>push.lua</b></h3></summary>
  
  ```lua
    local function include_helper(to, from, seen)
    	if from == nil then
    		return to
    	elseif type(from) ~= 'table' then
    		return from
    	elseif seen[from] then
    		return seen[from]
    	end
    
    	seen[from] = to
    	for k,v in pairs(from) do
    		k = include_helper({}, k, seen) -- keys might also be tables
    		if to[k] == nil then
    			to[k] = include_helper({}, v, seen)
    		end
    	end
    	return to
    end
    
    -- deeply copies `other' into `class'. keys in `other' that are already
    -- defined in `class' are omitted
    local function include(class, other)
    	return include_helper(class, other, {})
    end
    
    -- returns a deep copy of `other'
    local function clone(other)
    	return setmetatable(include({}, other), getmetatable(other))
    end
    
    local function new(class)
    	-- mixins
    	class = class or {}  -- class can be nil
    	local inc = class.__includes or {}
    	if getmetatable(inc) then inc = {inc} end
    
    	for _, other in ipairs(inc) do
    		if type(other) == "string" then
    			other = _G[other]
    		end
    		include(class, other)
    	end
    
    	-- class implementation
    	class.__index = class
    	class.init    = class.init    or class[1] or function() end
    	class.include = class.include or include
    	class.clone   = class.clone   or clone
    
    	-- constructor call
    	return setmetatable(class, {__call = function(c, ...)
    		local o = setmetatable({}, c)
    		o:init(...)
    		return o
    	end})
    end
    
    -- interface for cross class-system compatibility (see https://github.com/bartbes/Class-Commons).
    if class_commons ~= false and not common then
    	common = {}
    	function common.class(name, prototype, parent)
    		return new{__includes = {prototype, parent}}
    	end
    	function common.instance(class, ...)
    		return class(...)
    	end
    end
    
    
    -- the module
    return setmetatable({new = new, include = include, clone = clone},
    	{__call = function(_,...) return new(...) end})

  ```
</details>












<details>
  <summary><h3><b>StateMachine.lua</b></h3></summary>
  
  ```lua
    StateMachine = Class{}
    
    function StateMachine:init(states)
    	self.empty = {
    		render = function() end,
    		update = function() end,
    		processAI = function() end,
    		enter = function() end,
    		exit = function() end
    	}
    	self.states = states or {} -- [name] -> [function that returns states]
    	self.current = self.empty
    end
    
    function StateMachine:change(stateName, enterParams)
    	assert(self.states[stateName]) -- state must exist!
    	self.current:exit()
    	self.current = self.states[stateName]()
    	self.current:enter(enterParams)
    end
    
    function StateMachine:update(dt)
    	self.current:update(dt)
    end
    
    function StateMachine:render()
    	self.current:render()
    end
    
    
    function StateMachine:processAI(params, dt)
    	self.current:processAI(params, dt)
    end

  ```
</details>







<details>
  <summary><h3><b>Util.lua</b></h3></summary>
  
  ```lua
    function GenerateQuads(atlas, tilewidth, tileheight)
        local sheetWidth = atlas:getWidth() / tilewidth
        local sheetHeight = atlas:getHeight() / tileheight
    
        local sheetCounter = 1
        local spritesheet = {}
    
        for y = 0, sheetHeight - 1 do
            for x = 0, sheetWidth - 1 do
                spritesheet[sheetCounter] =
                    love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                    tileheight, atlas:getDimensions())
                sheetCounter = sheetCounter + 1
            end
        end
    
        return spritesheet
    end
    
    
    function print_r ( t )
        local print_r_cache={}
        local function sub_print_r(t,indent)
            if (print_r_cache[tostring(t)]) then
                print(indent.."*"..tostring(t))
            else
                print_r_cache[tostring(t)]=true
                if (type(t)=="table") then
                    for pos,val in pairs(t) do
                        if (type(val)=="table") then
                            print(indent.."["..pos.."] => "..tostring(t).." {")
                            sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                            print(indent..string.rep(" ",string.len(pos)+6).."}")
                        elseif (type(val)=="string") then
                            print(indent.."["..pos..'] => "'..val..'"')
                        else
                            print(indent.."["..pos.."] => "..tostring(val))
                        end
                    end
                else
                    print(indent..tostring(t))
                end
            end
        end
        if (type(t)=="table") then
            print(tostring(t).." {")
            sub_print_r(t,"  ")
            print("}")
        else
            sub_print_r(t,"  ")
        end
        print()
    end
  ```
</details>









<details>
  <summary><h3><b>main.lua</b></h3></summary>
  
  ```lua
    require 'src/dependencies'
    
    function love.load()
        love.window.setTitle('NYC Open Data Week 2025') -- appears at top of window
        love.graphics.setDefaultFilter('nearest', 'nearest') -- ensures graphics' clarity
    
        -- allows screen to adapt to dynamic resolutions and sizings
        push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {
            fullscreen = false,
            vsync = true,
            resizable = true
        })
    
        -- launch the visualization
        gStateMachine = StateMachine {
            ['play'] = function() return PlayState() end
        }
        gStateMachine:change('play')
    
        -- start music and make it loop
        gSounds['music']:setLooping(true)
        gSounds['music']:play()
    end
    
    function love.resize(w, h)
        push:resize(w, h)
    end
    
    function love.keypressed(key)
        love.keyboard.keysPressed[key] = true
        if key == "return" or key == "enter" then
            love.event.quit('restart')
        end
        if key == "escape" then
            love.event.quit() 
        end
    end
    
    function love.keyboard.wasPressed(key)
        return love.keyboard.keysPressed[key]
    end
    
    function love.update(dt)
        gStateMachine:update(dt)
        love.keyboard.keysPressed = {}
    end
    
    function love.draw()
        push:start()
        love.graphics.clear(192/255, 212/255, 112/255) -- light green background
        gStateMachine:render()
        push:finish()
    end
  ```
</details>


