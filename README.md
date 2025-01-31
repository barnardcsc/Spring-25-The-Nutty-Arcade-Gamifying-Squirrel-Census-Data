# Spring-25-The-Nutty-Arcade-Gamifying-Squirrel-Census-Data
NYC Open Data Week 2025 Workshop

```
function love.load()
    math.randomseed(os.time())
    love.window.setTitle('NYC Open Data Week 2025')
    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['play'] = function() return PlayState() end
    }
    gStateMachine:change('play')

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    love.keyboard.keysPressed = {}
end
```
