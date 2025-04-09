push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
WINNING_SCORE = 3

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Pong")

    math.randomseed(os.time())

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    player1 = Paddle(10, 30, 5, 30)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 30)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1Score = 0
    player2Score = 0
    servingPlayer = math.random(2) == 1 and 1 or 2
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.1
            ball.x = player1.x + 5
            sounds['paddle_hit']:play()
        elseif ball:collides(player2) then
            ball.dx = -ball.dx * 1.1
            ball.x = player2.x - 4
            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        elseif ball.y >= VIRTUAL_HEIGHT - ball.height then
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            player2Score = player2Score + 1
            sounds['score']:play()
            if player2Score == WINNING_SCORE then
                gameState = 'done'
                winningPlayer = 2
            else
                servingPlayer = 1
                ball:reset()
                gameState = 'start'
            end
        elseif ball.x > VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            sounds['score']:play()
            if player1Score == WINNING_SCORE then
                gameState = 'done'
                winningPlayer = 1
            else
                servingPlayer = 2
                ball:reset()
                gameState = 'start'
            end
        end

        ball:update(dt)
    end

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.printf("PONG", 0, 10, VIRTUAL_WIDTH, 'center')

    love.graphics.printf(player1Score, VIRTUAL_WIDTH / 2 - 100, 20, 50, 'center')
    love.graphics.printf(player2Score, VIRTUAL_WIDTH / 2 + 50, 20, 50, 'center')

    player1:render()
    player2:render()
    ball:render()

    if gameState == 'done' then
        love.graphics.printf("Player " .. winningPlayer .. " Wins!", 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
    end

    push:finish()
end
