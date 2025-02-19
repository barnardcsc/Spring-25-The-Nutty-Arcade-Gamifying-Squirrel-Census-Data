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
