
local int = require("modules.intMath")
local listener = require("modules.listener")
local etc = require("modules.etc")

local mx, my = term.getSize()
local players = {}
local apples = {}
local wl = 'a'

-- loops through each player and moves them based on what direction they are
-- facing
local function move()
  for i = 1, #players do
    local player = players[i]
    if player.dir == 0 then
      player.y = player.y - 1
    elseif player.dir == 2 then
      player.y = player.y + 1
    elseif player.dir == 1 then
      player.x = player.x + 1
    elseif player.dir == 3 then
      player.x = player.x - 1
    end
  end
end

-- loops through each player and draws their player
local function draw()
  -- TODO: Draw apples

  term.setBackgroundColor(colors.black)
  term.clear()

  for i = 1, #players do
    local player = players[i]
    term.setCursorPos(player.x, player.y)
    term.setBackgroundColor(colors.green)
    io.write(tostring(i))
  end
  term.setBackgroundColor(colors.black)
end

-- ticks the game
local function view()
  -- wait for the game to start
  os.pullEvent("start")

  -- game loop
  while true do
    move() -- move the players based on their direction
    draw() -- redraw the screen
    os.queueEvent("tick", players)
    -- queue a tick event with the players inputted
    -- somewhere else can handle the multiplayer part of this
    os.sleep(0.5)
  end
end

-- waits for "update" events, then updates the direction of the player based on
-- the updates

-- also calculates if a player has picked up an apple each tick
local function run()
  -- ensure this coroutine is the last coroutine ready
  print("Readying up")
  os.sleep(0.3)
  print("RUNNER GO")

  -- tell the other coroutines to start
  os.queueEvent("start", #players)

  -- game loop
  while true do
    local ev = {os.pullEvent()}
    if ev[1] == "update" then
      local player, dir = ev[2], ev[3]

      -- if the player is not trying to turn around...
      if players[player].dir ~= (dir + 2) % 4 then
        players[player].dir = dir
      end
    elseif ev[1] == "tick" then
      -- TODO: tick handling
    end
  end
end

local function main()
  -- get players
  print("How many players are playing? (1 - " .. tostring(listener.maxPlayers)
        .. ")")
  local plrs = etc.getInputInt(listener.maxPlayers)

  -- create players
  for i = 1, plrs do
    players[i] = {x = int.mul(mx, i / (plrs + 1)), y = int.div(my, 2), dir = 0}
  end

  -- launch game
  parallel.waitForAny(view, listener.listener, run)
end


local ok, err = pcall(main)

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

if not ok then
  printError(err)
end
