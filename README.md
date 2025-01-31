# Spring-25-The-Nutty-Arcade-Gamifying-Squirrel-Census-Data
NYC Open Data Week 2025 Workshop


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
