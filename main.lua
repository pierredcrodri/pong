local function clamp(x, m, n)
    if x < m then return m end
    if x > n then return n end
    return x
end

local function aabb(x, y, w, h, xx, yy, ww, hh)
    return x <= xx + ww and x + w >= xx and y <= yy + hh and y + h >= yy
end

local function choose(arr)
    return arr[love.math.random(1, #arr)]
end

local function number(x)
    if x == true then return 1 end
    if x == false then return 0 end
    return tonumber(x)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local PLAYER_SPEED = 200
local MARGIN = 32

local player_1 = {
    x = MARGIN,
    y = (love.graphics.getHeight() - 64) / 2,
    width = 16,
    height = 64,
    color = { 0.2, 0.2, 0.8, 1 },
    velocity = 0
}

local player_2 = {
    x = love.graphics.getWidth() - 16 - MARGIN,
    y = (love.graphics.getHeight() - 64) / 2,
    width = 16,
    height = 64,
    color = { 0.8, 0.2, 0.2, 1 },
    velocity = 0
}

local ball = {
    x = (love.graphics.getWidth() - 8) / 2,
    y = (love.graphics.getHeight() - 8) / 2,
    width = 8,
    height = 8,
    hspeed = choose({ -1, 1 }),
    vspeed = choose({ -1, -0.5, 0.5, 1 }),
    speed = 150
}

local state = "menu"
local ball_speed_timer = 0
local debug_mode = false
local score_1 = 0
local score_2 = 0

love.graphics.setDefaultFilter("nearest", "nearest")

if arg[2] then
    assert(arg[2] == "geoform.otf" or arg[2] == "random_wednesday.ttf", "Unknown font!")
end

local font = love.graphics.newFont(arg[2] or "random_wednesday.ttf", 64)
local small_font = love.graphics.newFont(arg[2] or "random_wednesday.ttf", 32)
love.graphics.setFont(font)

local reset_timer = 3
local pause_timer = 0
local winner = 0

function love.update(dt)
    if state == "gameplay" then
        ball_speed_timer = ball_speed_timer + dt
        if ball_speed_timer > 1 then
            ball_speed_timer = 0
            ball.speed = ball.speed + 3
        end

        -- Player 1

        local up_1 = number(love.keyboard.isDown("w"))
        local down_1 = number(love.keyboard.isDown("s"))

        player_1.velocity = lerp(player_1.velocity, (down_1 - up_1) * PLAYER_SPEED * dt, 0.25)

        player_1.y = player_1.y + player_1.velocity
        player_1.y = clamp(player_1.y, 0, love.graphics.getHeight() - player_1.height)

        -- Player 2

        local up_2 = number(love.keyboard.isDown("up"))
        local down_2 = number(love.keyboard.isDown("down"))

        player_2.velocity = lerp(player_2.velocity, (down_2 - up_2) * PLAYER_SPEED * dt, 0.25)

        player_2.y = player_2.y + player_2.velocity
        player_2.y = clamp(player_2.y, 0, love.graphics.getHeight() - player_1.height)

        -- Ball

        ball.x = ball.x + ball.hspeed * ball.speed * dt
        ball.y = ball.y + ball.vspeed * ball.speed * dt

        if ball.y < 0 then
            ball.vspeed = math.abs(ball.vspeed)
        end

        if ball.y > love.graphics.getHeight() - ball.height then
            ball.vspeed = -ball.vspeed
        end

        if aabb(ball.x, ball.y, ball.width, ball.height, player_1.x, player_1.y, player_1.width, player_1.height) then
            local ball_center_y = ball.y + ball.height / 2
            local player_center_y = player_1.y + player_1.height / 2

            local d = player_center_y - ball_center_y
            ball.vspeed = clamp(ball.vspeed + d * -0.05, -1.5, 1.5)
            ball.hspeed = 1
        end

        if aabb(ball.x, ball.y, ball.width, ball.height, player_2.x, player_2.y, player_2.width, player_2.height) then
            local ball_center_y = ball.y + ball.height / 2
            local player_center_y = player_2.y + player_2.height / 2

            local d = player_center_y - ball_center_y
            ball.vspeed = clamp(ball.vspeed + d * -0.05, -1.5, 1.5)
            ball.hspeed = -1
        end

        if ball.x < 0 then
            -- Player 2 wins
            state = "reset"
            reset_timer = 4
            score_2 = score_2 + 1
            winner = 2
        end

        if ball.x > love.graphics.getWidth() then
            -- Player 1 wins
            state = "reset"
            reset_timer = 4
            score_1 = score_1 + 1
            winner = 1
        end
    elseif state == "pause" then
        pause_timer = pause_timer - dt
        if pause_timer <= 0 then
            pause_timer = 3
        end
    elseif state == "reset" then
        reset_timer = reset_timer - dt
        if reset_timer <= 0 then
            winner = 0
            state = "gameplay"
            player_1 = {
                x = MARGIN,
                y = (love.graphics.getHeight() - 64) / 2,
                width = 16,
                height = 64,
                color = { 0.2, 0.2, 0.8, 1 },
                velocity = 0
            }
            player_2 = {
                x = love.graphics.getWidth() - 16 - MARGIN,
                y = (love.graphics.getHeight() - 64) / 2,
                width = 16,
                height = 64,
                color = { 0.8, 0.2, 0.2, 1 },
                velocity = 0
            }
            ball = {
                x = (love.graphics.getWidth() - 8) / 2,
                y = (love.graphics.getHeight() - 8) / 2,
                width = 8,
                height = 8,
                hspeed = choose({ -1, 1 }),
                vspeed = choose({ -1, -0.5, 0.5, 1 }),
                speed = 150
            }
        end
    end
end

function love.draw()
    local font_height = font:getHeight()

    love.graphics.setColor(player_1.color)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth() / 2, love.graphics.getHeight())

    love.graphics.setColor(player_2.color)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2, 0, love.graphics.getWidth() / 2,
        love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player_1.x, player_1.y, player_1.width, player_1.height)
    love.graphics.rectangle("fill", player_2.x, player_2.y, player_2.width, player_2.height)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)

    if debug_mode then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(tostring(ball_speed_timer) .. " " .. tostring(ball.speed))
    end

    if state ~= "gameplay" then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    if state == "menu" then
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            "Pongi",
            (love.graphics.getWidth() - font:getWidth("Pongi")) / 2,
            ((love.graphics.getHeight() - font_height) / 2) - 50
        )

        love.graphics.setFont(small_font)
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.print(
            "Press any key to start",
            (love.graphics.getWidth() - small_font:getWidth("Press any key to start")) / 2,
            ((love.graphics.getHeight() - small_font:getHeight()) / 2) + 20
        )
    elseif state == "reset" then
        local text = tostring(reset_timer)
        if reset_timer < 4 and reset_timer > 3 then
            text = "3"
        end
        if reset_timer < 3 and reset_timer > 2 then
            text = "2"
        end
        if reset_timer < 2 and reset_timer > 1 then
            text = "1"
        end
        if reset_timer < 1 then
            text = "Go!"
        end

        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            text,
            (love.graphics.getWidth() - font:getWidth(text)) / 2,
            ((love.graphics.getHeight() - font_height) / 2) - 50
        )

        if winner == 1 or winner == 2 then
            local text_2 = winner == 1 and "Player 1 scores!" or "Player 2 scores!"

            love.graphics.setFont(small_font)
            love.graphics.setColor(1, 1, 1, 0.75)
            love.graphics.print(
                text_2,
                (love.graphics.getWidth() - small_font:getWidth(text_2)) / 2,
                ((love.graphics.getHeight() - small_font:getHeight()) / 2) + 20
            )
        end
    elseif state == "pause" then
        local text = "Paused"
        if pause_timer < 3 and pause_timer > 2 then
            text = text .. "..."
        end
        if pause_timer < 2 and pause_timer > 1 then
            text = text .. ".."
        end
        if pause_timer < 1 then
            text = text .. "."
        end

        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            text,
            (love.graphics.getWidth() - font:getWidth(text)) / 2,
            ((love.graphics.getHeight() - font_height) / 2)
        )
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(font)
        local text = tostring(score_1) .. " | " .. tostring(score_2)
        love.graphics.print(
            text,
            (love.graphics.getWidth() - font:getWidth(text)) / 2,
            MARGIN
        )
    end
end

function love.keypressed(key)
    if key == "f1" then
        debug_mode = not debug_mode
    end
    if state == "menu" then
        state = "reset"
        reset_timer = 4
    end
    if state == "gameplay" and key == "escape" then
        state = "pause"
        pause_timer = 3
        return
    end
    if state == "pause" then
        state = "gameplay"
    end
end
