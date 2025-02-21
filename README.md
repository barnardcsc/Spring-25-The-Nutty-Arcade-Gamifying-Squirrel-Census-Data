# Spring-25-The-Nutty-Arcade-Gamifying-Squirrel-Census-Data

The Nutty Arcade: Gamifying Squirrel Census Data

NYC Open Data Week 2025 Workshop

Presented by **Kiley Matschke** (Post-Baccalaureate Fellow, Barnard College Vagelos Computational Science Center)

### **Dataset:** [Squirrel Census Data](https://www.dropbox.com/scl/fi/is2yaa5gz1of32xo1xwvd/squirrel-data.csv?rlkey=sao5wj2tqd98nzs6rsi5k7ot6&e=2&dl=0)

### **Environment Setup (The tools necessary to build our game!)**

1. [Download Visual Studio Code](https://code.visualstudio.com/Download)
2. [Download LÖVE](https://love2d.org/)

### **Download the project template [here](https://drive.google.com/drive/folders/1sw_HqMAoGe-OUD2Q_HwDxi8FXagq2Q7u?usp=drive_link)** ###


### **Game Resources:**

1. [Sprite Lands Asset Pack](https://cupnooble.itch.io/sprout-lands-asset-pack) (Environment + main character)
2. [SunnyLand Woods Asset Pack](https://ansimuz.itch.io/sunnyland-woods) (Brown squirrels)
3. [Itch.io](http://Itch.io) (Place to find lots of game-related resources)
4. [Figma](http://figma.com) (Great for designing/modifying assets)
5. [Dafont](https://www.dafont.com/) (Fonts)
6. [Cozy Animal Crossing Music](https://youtu.be/8kBlKM71pjc?si=20Xfh4WgZb2Sj34r) (Soundtrack)
<img width="300" alt="Squirrels Sprite Sheet" src="https://github.com/user-attachments/assets/4ffa9517-888b-4d09-ae54-0c8155433054" />
<img width="215" height="215" alt="Character Sprite Sheet" src="https://github.com/user-attachments/assets/861bc49f-eee1-4f24-992e-6ac2d335d3ed" />
<img width="300" alt="Grass Sprite Sheet" src="https://github.com/user-attachments/assets/f8217443-9cd3-44ff-9dbf-ae7473ea5bfd" />


### **Running your game**

1. Once your code is thorough enough to begin running your game, open your laptop's terminal
2. Navigate to the folder location of your game by typing: “cd [insert folder name here]”
3. Run **C:\Program Files\LOVE\love.exe .** on Windows or **/Applications/love.app/Contents/MacOS/love .** on Mac (don't forget the period at the end!)


## **Project hierarchy**

**Parent folder: squirrels**

| Sub-folders       | Contents           |
| :-------------: |:-------------:| 
| fonts         | hipchick.ttf |
| graphics | grass.png, player.png, squirrels.png, tree.png  |   
| lib            | Animation.lua, class.lua, push.lua, StateMachine.lua, Util.lua    |   
| sounds        | animalcrossing.wav      |   
| src            | Area.lua, dependencies.lua, entity_defs.lua, Player.lua, PlayState.lua, squirrel-data.csv, Squirrel.lua | 
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
  local love11 = love.getVersion() == 11
  local getDPI = love11 and love.window.getDPIScale or love.window.getPixelScale
  local windowUpdateMode = love11 and love.window.updateMode or function(width, height, settings)
    local _, _, flags = love.window.getMode()
    for k, v in pairs(settings) do flags[k] = v end
    love.window.setMode(width, height, flags)
  end
  
  local push = {
    
    defaults = {
      fullscreen = false,
      resizable = false,
      pixelperfect = false,
      highdpi = true,
      canvas = true,
      stencil = true
    }
    
  }
  setmetatable(push, push)
  
  function push:applySettings(settings)
    for k, v in pairs(settings) do
      self["_" .. k] = v
    end
  end
  
  function push:resetSettings() return self:applySettings(self.defaults) end
  
  function push:setupScreen(WWIDTH, WHEIGHT, RWIDTH, RHEIGHT, settings)
  
    settings = settings or {}
  
    self._WWIDTH, self._WHEIGHT = WWIDTH, WHEIGHT
    self._RWIDTH, self._RHEIGHT = RWIDTH, RHEIGHT
  
    self:applySettings(self.defaults) --set defaults first
    self:applySettings(settings) --then fill with custom settings
    
    windowUpdateMode(self._RWIDTH, self._RHEIGHT, {
      fullscreen = self._fullscreen,
      resizable = self._resizable,
      highdpi = self._highdpi
    })
  
    self:initValues()
  
    if self._canvas then
      self:setupCanvas({ "default" }) --setup canvas
    end
  
    self._borderColor = {0, 0, 0}
  
    self._drawFunctions = {
      ["start"] = self.start,
      ["end"] = self.finish
    }
  
    return self
  end
  
  function push:setupCanvas(canvases)
    table.insert(canvases, { name = "_render", private = true }) --final render
  
    self._canvas = true
    self.canvases = {}
  
    for i = 1, #canvases do
      push:addCanvas(canvases[i])
    end
  
    return self
  end
  function push:addCanvas(params)
    table.insert(self.canvases, {
      name = params.name,
      private = params.private,
      shader = params.shader,
      canvas = love.graphics.newCanvas(self._WWIDTH, self._WHEIGHT),
      stencil = params.stencil or self._stencil
    })
  end
  
  function push:setCanvas(name)
    if not self._canvas then return true end
    local canvasTable = self:getCanvasTable(name)
    return love.graphics.setCanvas({ canvasTable.canvas, stencil = canvasTable.stencil })
  end
  function push:getCanvasTable(name)
    for i = 1, #self.canvases do
      if self.canvases[i].name == name then
        return self.canvases[i]
      end
    end
  end
  function push:setShader(name, shader)
    if not shader then
      self:getCanvasTable("_render").shader = name
    else
      self:getCanvasTable(name).shader = shader
    end
  end
  
  function push:initValues()
    self._PSCALE = (not love11 and self._highdpi) and getDPI() or 1
    
    self._SCALE = {
      x = self._RWIDTH/self._WWIDTH * self._PSCALE,
      y = self._RHEIGHT/self._WHEIGHT * self._PSCALE
    }
    
    if self._stretched then --if stretched, no need to apply offset
      self._OFFSET = {x = 0, y = 0}
    else
      local scale = math.min(self._SCALE.x, self._SCALE.y)
      if self._pixelperfect then scale = math.floor(scale) end
      
      self._OFFSET = {x = (self._SCALE.x - scale) * (self._WWIDTH/2), y = (self._SCALE.y - scale) * (self._WHEIGHT/2)}
      self._SCALE.x, self._SCALE.y = scale, scale --apply same scale to X and Y
    end
    
    self._GWIDTH = self._RWIDTH * self._PSCALE - self._OFFSET.x * 2
    self._GHEIGHT = self._RHEIGHT * self._PSCALE - self._OFFSET.y * 2
  end
  
  function push:apply(operation, shader)
    self._drawFunctions[operation](self, shader)
  end
  
  function push:start()
    if self._canvas then
      love.graphics.push()
      love.graphics.setCanvas({ self.canvases[1].canvas, stencil = self.canvases[1].stencil })
  
    else
      love.graphics.translate(self._OFFSET.x, self._OFFSET.y)
      love.graphics.setScissor(self._OFFSET.x, self._OFFSET.y, self._WWIDTH*self._SCALE.x, self._WHEIGHT*self._SCALE.y)
      love.graphics.push()
      love.graphics.scale(self._SCALE.x, self._SCALE.y)
    end
  end
  
  function push:applyShaders(canvas, shaders)
    local _shader = love.graphics.getShader()
    if #shaders <= 1 then
      love.graphics.setShader(shaders[1])
      love.graphics.draw(canvas)
    else
      local _canvas = love.graphics.getCanvas()
  
      local _tmp = self:getCanvasTable("_tmp")
      if not _tmp then --create temp canvas only if needed
        self:addCanvas({ name = "_tmp", private = true, shader = nil })
        _tmp = self:getCanvasTable("_tmp")
      end
  
      love.graphics.push()
      love.graphics.origin()
      local outputCanvas
      for i = 1, #shaders do
        local inputCanvas = i % 2 == 1 and canvas or _tmp.canvas
        outputCanvas = i % 2 == 0 and canvas or _tmp.canvas
        love.graphics.setCanvas(outputCanvas)
        love.graphics.clear()
        love.graphics.setShader(shaders[i])
        love.graphics.draw(inputCanvas)
        love.graphics.setCanvas(inputCanvas)
      end
      love.graphics.pop()
  
      love.graphics.setCanvas(_canvas)
      love.graphics.draw(outputCanvas)
    end
    love.graphics.setShader(_shader)
  end
  
  function push:finish(shader)
    love.graphics.setBackgroundColor(unpack(self._borderColor))
    if self._canvas then
      local _render = self:getCanvasTable("_render")
  
      love.graphics.pop()
  
      local white = love11 and 1 or 255
      love.graphics.setColor(white, white, white)
  
      --draw canvas
      love.graphics.setCanvas(_render.canvas)
      for i = 1, #self.canvases do --do not draw _render yet
        local _table = self.canvases[i]
        if not _table.private then
          local _canvas = _table.canvas
          local _shader = _table.shader
          self:applyShaders(_canvas, type(_shader) == "table" and _shader or { _shader })
        end
      end
      love.graphics.setCanvas()
      
      --draw render
      love.graphics.translate(self._OFFSET.x, self._OFFSET.y)
      local shader = shader or _render.shader
      love.graphics.push()
      love.graphics.scale(self._SCALE.x, self._SCALE.y)
      self:applyShaders(_render.canvas, type(shader) == "table" and shader or { shader })
      love.graphics.pop()
  
      --clear canvas
      for i = 1, #self.canvases do
        love.graphics.setCanvas(self.canvases[i].canvas)
        love.graphics.clear()
      end
  
      love.graphics.setCanvas()
      love.graphics.setShader()
    else
      love.graphics.pop()
      love.graphics.setScissor()
    end
  end
  
  function push:setBorderColor(color, g, b)
    self._borderColor = g and {color, g, b} or color
  end
  
  function push:toGame(x, y)
    x, y = x - self._OFFSET.x, y - self._OFFSET.y
    local normalX, normalY = x / self._GWIDTH, y / self._GHEIGHT
    
    x = (x >= 0 and x <= self._WWIDTH * self._SCALE.x) and normalX * self._WWIDTH or nil
    y = (y >= 0 and y <= self._WHEIGHT * self._SCALE.y) and normalY * self._WHEIGHT or nil
    
    return x, y
  end
  
  function push:toReal(x, y)
    return x + self._OFFSET.x, y + self._OFFSET.y
  end
  
  function push:switchFullscreen(winw, winh)
    self._fullscreen = not self._fullscreen
    local windowWidth, windowHeight = love.window.getDesktopDimensions()
    
    if self._fullscreen then --save windowed dimensions for later
      self._WINWIDTH, self._WINHEIGHT = self._RWIDTH, self._RHEIGHT
    elseif not self._WINWIDTH or not self._WINHEIGHT then
      self._WINWIDTH, self._WINHEIGHT = windowWidth * .5, windowHeight * .5
    end
    
    self._RWIDTH = self._fullscreen and windowWidth or winw or self._WINWIDTH
    self._RHEIGHT = self._fullscreen and windowHeight or winh or self._WINHEIGHT
    
    self:initValues()
    
    love.window.setFullscreen(self._fullscreen, "desktop")
    if not self._fullscreen and (winw or winh) then
      windowUpdateMode(self._RWIDTH, self._RHEIGHT) --set window dimensions
    end
  end
  
  function push:resize(w, h)
    if self._highdpi then w, h = w / self._PSCALE, h / self._PSCALE end
    self._RWIDTH = w
    self._RHEIGHT = h
    self:initValues()
  end
  
  function push:getWidth() return self._WWIDTH end
  function push:getHeight() return self._WHEIGHT end
  function push:getDimensions() return self._WWIDTH, self._WHEIGHT end
  
  return push


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
    VIRTUAL_WIDTH = 1280 
    VIRTUAL_HEIGHT = 720 
    
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
        if key == "return" or key == "enter" then -- resets park every time you hit enter
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


