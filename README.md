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

1. [SunnyLand Woods Asset Pack](https://ansimuz.itch.io/sunnyland-woods) (Brown squirrels)
2. [Sprite Lands Asset Pack](https://cupnooble.itch.io/sprout-lands-asset-pack) (Environment + main character)
3. [Figma](http://figma.com) (Great for designing/modifying assets)
4. [Dafont](https://www.dafont.com/) (Fonts)
5. [Cozy Animal Crossing Music](https://youtu.be/8kBlKM71pjc?si=20Xfh4WgZb2Sj34r) (Soundtrack)
6. Labeled sprite sheets:
<img width="300" height="215" alt="Squirrels Sprite Sheet" src="https://github.com/user-attachments/assets/4ffa9517-888b-4d09-ae54-0c8155433054" />
<img width="215" height="215" alt="Character Sprite Sheet" src="https://github.com/user-attachments/assets/861bc49f-eee1-4f24-992e-6ac2d335d3ed" />
<img width="300" height="215" alt="Grass Sprite Sheet" src="https://github.com/user-attachments/assets/f8217443-9cd3-44ff-9dbf-ae7473ea5bfd" />


### **Running your game**

1. Once your code is thorough enough to begin running your game, open your laptop's terminal
2. Navigate to the folder location of your game by typing: “cd [insert folder name here]”
3. Run **C:\Program Files\LOVE\love.exe .** on Windows or **/Applications/love.app/Contents/MacOS/love .** on Mac (don't forget the period at the end!)


## **Project hierarchy (the final result!)**

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


