# Spring-25-The-Nutty-Arcade-Gamifying-Squirrel-Census-Data

The Nutty Arcade: Gamifying Squirrel Census Data

NYC Open Data Week 2025 Workshop

Presented by **Kiley Matschke** (Post-Baccalaureate Fellow, Barnard College Vagelos Computational Science Center)

### **Dataset:** [Squirrel Census Data](https://www.dropbox.com/scl/fi/is2yaa5gz1of32xo1xwvd/squirrel-data.csv?rlkey=sao5wj2tqd98nzs6rsi5k7ot6&e=2&dl=0)

### **Environment setup (the tools necessary to build our game!):**

1. [Download Visual Studio Code](https://code.visualstudio.com/Download)
2. [Download LÖVE](https://love2d.org/) and add it to Applications (on Mac) or Program Files (on Windows)
3. [Download workshop template](https://drive.google.com/drive/folders/1HWq2Vm4AxOYPZMD87tMVISUnAy01wzmB?usp=drive_link)


### **Game resources:**

1. [SunnyLand Woods Asset Pack](https://ansimuz.itch.io/sunnyland-woods) (Cinnamon squirrels)
2. [Sprout Lands Asset Pack](https://cupnooble.itch.io/sprout-lands-asset-pack) (Player + environment)
3. [Figma](http://figma.com) (Great for designing and modifying assets)
4. [Dafont](https://www.dafont.com/) (Fonts)
5. [Cozy Animal Crossing Music](https://youtu.be/8kBlKM71pjc?si=20Xfh4WgZb2Sj34r) (Soundtrack)
6. Labeled sprite sheets:
<img width="155" height="215" alt="Screenshot 2025-02-26 at 8 09 52 PM" src="https://github.com/user-attachments/assets/cf662058-8055-48db-a4b8-2bce5f9d00f6" />
<img width="215" height="215" alt="Character Sprite Sheet" src="https://github.com/user-attachments/assets/861bc49f-eee1-4f24-992e-6ac2d335d3ed" />
<img width="300" height="215" alt="Grass Sprite Sheet" src="https://github.com/user-attachments/assets/f8217443-9cd3-44ff-9dbf-ae7473ea5bfd" />

7. Coordinate plane:
<img width="650" height="320" alt="Screenshot 2025-03-04 at 7 02 16 PM" src="https://github.com/user-attachments/assets/dd6cc686-572f-4b2d-b966-84f5b65e2781" />





## **Code from the workshop**


<details>
  <summary><h3><b>dependencies.lua</b></h3></summary>
  
  ```lua
      Class = require 'lib/class'
      push = require 'lib/push'
      require 'lib/Animation'
      require 'lib/StateMachine'
      require 'lib/Util'
      
      require 'src/entity_defs'
      require 'src/Player'
      require 'src/PlayState'
      require 'src/Grass'
      require 'src/Squirrel'
      
      
      gFonts = {
          ['large'] = love.graphics.newFont('fonts/hipchick.ttf', 45)
      }
      
      
      gSounds = {
          ['music'] = love.audio.newSource('sounds/animalcrossing.wav', 'stream')
      }
      
      
      gTextures = {
          ['player'] = love.graphics.newImage('graphics/player.png'),
          ['grass'] = love.graphics.newImage('graphics/grass.png'),
          ['squirrels'] = love.graphics.newImage('graphics/squirrels.png'),
          ['tree'] = love.graphics.newImage('graphics/tree.png')
      }
      
      
      gFrames = {
          ['player'] = GenerateQuads(gTextures['player'], 48, 48),
          ['grass'] = GenerateQuads(gTextures['grass'], 64, 64),
          ['squirrels'] = GenerateQuads(gTextures['squirrels'], 32, 32)
      }
  ```
</details>






<details>
  <summary><h3><b>main.lua</b></h3></summary>
  
  ```lua
      require 'src/dependencies'
      
      VIRTUAL_WIDTH = 1280
      VIRTUAL_HEIGHT = 720
      
      
      function love.load()
          love.window.setTitle('NYC Open Data Week 2025')
          love.graphics.setDefaultFilter('nearest', 'nearest')
      
          push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, {
              fullscreen = false, 
              vsync = true, 
              rezibale = true
          })
      
          gStateMachine = StateMachine {
              ['play'] = function() return PlayState() end
          }
          gStateMachine:change('play')
      
          gSounds['music']:setLooping(true)
          gSounds['music']:play()
      end
      
      
      function love.resize(w,h)
          push:resize(w,h)
      end
      
      
      function love.keypressed(key)
          love.keyboard.keysPressed[key] = true
          if key == 'return' or key == 'enter' then
              love.event.quit('restart')
          end
          if key == 'escape' then
              love.event.quit()
          end
      end
      
      
      function love.update(dt)
          love.keyboard.keysPressed = {}
          gStateMachine:update(dt)
      end
      
      
      function love.draw()
          push:start()
          love.graphics.clear(192/255, 212/255, 112/255)
          gStateMachine:render()
          push:finish()
      end
  ```
</details>







<details>
  <summary><h3><b>entity_defs.lua</b></h3></summary>
  
  ```lua
      ENTITY_DEFS = {
          ['player'] = {
              animations = {
                  ['walk-down'] = {frames = {1,2,3,4}, interval = 0.25, texture = 'player'},
                  ['walk-up'] = {frames = {5,6,7,8}, interval = 0.25, texture = 'player'},
                  ['walk-left'] = {frames = {9,10,11,12}, interval = 0.25, texture = 'player'},
                  ['walk-right'] = {frames = {13,14,15,16}, interval = 0.25, texture = 'player'},
      
                  ['idle-down'] = {frames = {1}, interval = 0, texture = 'player'},
                  ['idle-up'] = {frames = {5}, interval = 0, texture = 'player'},
                  ['idle-left'] = {frames = {9}, interval = 0, texture = 'player'},
                  ['idle-right'] = {frames = {13}, interval = 0, texture = 'player'},
              }
          },
      
      
          ['gray-squirrel'] = {
              animations = {
                  ['wag-tail'] = {frames = {1,2}, interval = 0.5, texture = 'squirrels'}
              }
          },
      
          ['cinnamon-squirrel'] = {
              animations = {
                  ['wag-tail'] = {frames = {3,4}, interval = 0.5, texture = 'squirrels'}
              }
          },
      
          ['black-squirrel'] = {
              animations = {
                  ['wag-tail'] = {frames = {5,6}, interval = 0.5, texture = 'squirrels'}
              }
          }
      }
  ```
</details>







<details>
  <summary><h3><b>Player.lua</b></h3></summary>
  
  ```lua
      Player = Class{}
      
      
      function Player:init()
          self.speed = 300
          self.x = 1
          self.y = 1
          self.animations = {}
      
          for direction, def in pairs(ENTITY_DEFS['player'].animations) do
              self.animations[direction] = Animation(def)
          end
      
          self.direction = 'idle-down'
          self.currentAnimation = self.animations[self.direction]
      end 
      
      
      function Player:update(dt)
          if love.keyboard.isDown('down') then
              self.direction = 'walk-down'
              self.y = self.y + self.speed * dt
          elseif love.keyboard.isDown('up') then
              self.direction = 'walk-up'
              self.y = self.y - self.speed * dt
          elseif love.keyboard.isDown('left') then
              self.direction = 'walk-left'
              self.x = self.x - self.speed * dt
          elseif love.keyboard.isDown('right') then
              self.direction = 'walk-right'
              self.x = self.x + self.speed * dt
          else
              self.direction = 'idle-' .. self.direction:sub(6)
          end
      
          self.currentAnimation = self.animations[self.direction]
          self.currentAnimation:update(dt)
      end
      
      
      function Player:render()
          self.currentAnimation:render(self.x, self.y)
      end
  ```
</details>








<details>
  <summary><h3><b>PlayState.lua</b></h3></summary>
  
  ```lua
      PlayState = Class{}
      
      
      function PlayState:init()
          self.player = Player()
          self.grass = Grass()
      
          local csv = require('lib/csv')
          local file = io.open('src/squirrel-data.csv', 'r')
          local data = file:read('*a')
          file:close()
      
          local parks, park_names = {}, {}
          local parsed_data = csv.openstring(data, {header=true})
          for row in parsed_data:lines() do 
              parks[row.Park] = parks[row.Park] or {}
              table.insert(parks[row.Park], row)
          end
          for park_name in pairs(parks) do
              table.insert(park_names, park_name)
          end
      
          self.squirrels = {}
          local function add_squirrel(row,color)
              local x = math.random(128, VIRTUAL_WIDTH-128)
              local y = math.random(128, VIRTUAL_HEIGHT-144)
              local above_ground = string.find(row.Location, 'Above Ground') and true or false
              table.insert(self.squirrels, {squirrel = Squirrel(x,y,color, above_ground), x=x, y=y})
          end
      
          self.selected_park = park_names[math.random(#park_names)]
          self.gray_count, self.cinnamon_count, self.black_count = 0,0,0
          for index, row in ipairs(parks[self.selected_park]) do 
              if row.Color == 'Gray' then
                  self.gray_count = self.gray_count + 1
                  add_squirrel(row, 'gray')
              elseif row.Color == 'Cinnamon' then 
                  self.cinnamon_count = self.cinnamon_count + 1
                  add_squirrel(row, 'cinnamon')
              elseif row.Color == 'Black' then 
                  self.black_count = self.black_count + 1
                  add_squirrel(row, 'black')
              end
          end
      end 
      
      
      function PlayState:update(dt)
          self.player:update(dt)
      
          for index, squirrelData in ipairs(self.squirrels) do
              squirrelData.squirrel:update(dt)
          end
      end
      
      
      function PlayState:render()
          love.graphics.push()
          self.grass:render()
          self.player:render()
      
          for index, squirrelData in ipairs(self.squirrels) do
              squirrelData.squirrel:render(squirrelData.x, squirrelData.y)
          end
      
          love.graphics.setFont(gFonts['large'])
          love.graphics.setColor(103/255, 145/255, 70/255, 1)
          love.graphics.printf(self.selected_park, 0, 32, VIRTUAL_WIDTH, 'center')
          love.graphics.printf(string.format('Gray: ' .. self.gray_count .. '    Cinnamon:  ' .. self.cinnamon_count .. '    Black:  ' .. self.black_count),
                                              0, VIRTUAL_HEIGHT-96, VIRTUAL_WIDTH, 'center')
          love.graphics.pop()
      end
      
      
      function PlayState:enter() end
      function PlayState:exit() end
  ```
</details>





<details>
  <summary><h3><b>Grass.lua</b></h3></summary>
  
  ```lua
      Grass = Class{}
      
      
      function Grass:init()
          self.tile_size = 64
          self.width = VIRTUAL_WIDTH/self.tile_size
          self.height = math.floor(VIRTUAL_HEIGHT/self.tile_size)
          self.tiles = {}
          self:generate_grass()
      end
      
      
      function Grass:generate_grass()
          for y = 1, self.height do
              table.insert(self.tiles, {})
      
              for x = 1, self.width do
                  if x == 1 and y == 1 then id = 1
                  elseif x == 1 and y == self.height then id = 23
                  elseif x == self.width and y == 1 then id = 3
                  elseif x == self.width and y == self.height then id = 25
      
                  elseif x == 1 then id = 12
                  elseif x == self.width then id = 14
                  elseif y == 1 then id = 2
                  elseif y == self.height then id = 24
                  
                  else id = math.random(56, 77) end
      
                  table.insert(self.tiles[y], {id = id})
              end
          end
      end
      
      
      function Grass:render()
          for y = 1, self.height do
              for x = 1, self.width do
                  local tile = self.tiles[y][x]
                  love.graphics.draw(gTextures['grass'], gFrames['grass'][tile.id], (x-1)*self.tile_size, (y-1)*self.tile_size)
              end
          end
      end
  ```
</details>





<details>
  <summary><h3><b>Squirrel.lua</b></h3></summary>
  
  ```lua
      Squirrel = Class{}
      
      
      function Squirrel:init(x, y, color, above_ground)
          self.x = x
          self.y = y
          self.color = color
          self.above_ground = above_ground
      
          self.animations = {}
          local squirrelDef = ENTITY_DEFS[color .. '-squirrel']
          for direction, def in pairs(squirrelDef.animations) do
              self.animations[direction] = Animation(def)
          end
      
          self.currentAnimation = self.animations['wag-tail']
      end
      
      
      function Squirrel:update(dt)
          self.currentAnimation:update(dt)
      end
      
      
      function Squirrel:render(x,y)
          if self.above_ground then love.graphics.draw(gTextures['tree'], x, y) end
      
          self.currentAnimation:render(x,y)
      end
  ```
</details>







## **Final project hierarchy**

**Parent folder: squirrels-template**

| Sub-folders       | Contents           |
| :-------------: |:-------------:| 
| fonts         | hipchick.ttf |
| graphics | grass.png, player.png, squirrels.png, tree.png  |   
| lib            | Animation.lua, class.lua, csv.lua, push.lua, StateMachine.lua, Util.lua    |   
| sounds        | animalcrossing.wav      |   
| src            | dependencies.lua, entity_defs.lua, Grass.lua, Player.lua, PlayState.lua, squirrel-data.csv, Squirrel.lua | 
| main.lua (file)        |    








## **Running your game**

1. Open your laptop's terminal
2. Navigate to the ```squirrels-template``` folder. 

   For example, if ```squirrels-template``` is in your Downloads, type: "cd Downloads/squirrels-template" and then hit enter
   
3. Run **/Applications/love.app/Contents/MacOS/love .** on Mac or **C:\Program Files\LOVE\love.exe .** on Windows (don't forget the period at the end!)
