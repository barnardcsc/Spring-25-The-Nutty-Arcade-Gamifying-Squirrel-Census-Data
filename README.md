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


**main.lua**
```lua
require 'src/Dependencies'

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


**
