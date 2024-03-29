local tArgs = {...}

local debugg = false
local int = require("modules.intMath")
local listener = require("modules.listener")
local etc = require("modules.etc")

local tickSpeed = 0.2
local mx, my = term.getSize()
local players = {}
local apples = {}
local wl = 'a'

if tArgs[1] == "debug" then
  debugg = true
end

-- returns the position of all snake parts
local function calcSnakePos(queue, tx, ty)
  local ret = {{tx, ty}}

  for i = 1, #queue - 1 do
    tx, ty = etc.sim(tx, ty, queue[i])
    ret[#ret + 1] = {tx, ty}
  end

  return ret
end

-- loops through each player and draws their player
local function draw()
  term.setBackgroundColor(colors.black)
  term.clear()

  -- Draw the apples
  for i = 1, #apples do
    local c = apples[i]
    term.setCursorPos(c[1], c[2])
    term.setBackgroundColor(colors.red)
    io.write(' ')
  end

  -- draw players and their tails
  for i = 1, #players do
    local player = players[i]
    -- draw head
    term.setCursorPos(player.x, player.y)
    term.setBackgroundColor(colors.green)
    io.write(tostring(i))

    -- draw tail
    term.setCursorPos(player.tx, player.ty)
    term.setBackgroundColor(colors.orange)
    io.write(' ')

    -- draw snek
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(player.tx, player.ty)
    for j = 2, #player.tailQueue do
      etc.moveCursor(player.tailQueue[j])
      io.write(' ')
      etc.moveCursor(3)
    end
  end
  term.setBackgroundColor(colors.black)
end

local function debug()
  if debugg then
    term.setCursorPos(1, 1)
    local x, y = term.getSize()
    term.write("1234567890123456789012345678901234567890123456789012345678901234567890")
    print()
    for i, player in ipairs(players) do
      print("hp:", player.x, player.y)
      print("tp:", player.tx, player.ty)
      print("  q:", table.unpack(player.tailQueue))
      print()

      local pPos = calcSnakePos(player.tailQueue, player.tx, player.ty)
      for j, pos in ipairs(pPos) do
        print("  p" .. tostring(j) .. ":", pos[1], pos[2])
      end
    end
    for i = 1, y do
      term.setCursorPos(x, i)
      io.write(i%10)
    end
  end
end

local function updateDirection()
  for i = 1, #players do
    -- loop through each player, update their last direction
    local player = players[i]
    player.ldir = player.dir

    -- loop through each player, check the tailQueue
    if player.lengthLeft == 0 then
      table.remove(player.tailQueue, 1)
      player.tdir = player.tailQueue[1]
    end
    player.tailQueue[#player.tailQueue + 1] = player.dir
  end
end

-- loops through each player and moves them based on what direction they are
-- facing
local function move()
  print("MOVE")
  for i = 1, #players do
    local player = players[i]
    -- head
    player.x, player.y = etc.sim(player.x, player.y, player.dir)

    -- tail
    if player.lengthLeft == 0 then
      player.tx, player.ty = etc.sim(player.tx, player.ty, player.tdir)
    end
  end

end

-- ticks the game
local function view()
  -- wait for the game to start
  os.pullEvent("start")

  -- game loop
  while true do
    move() -- move the players based on their direction
    draw() -- redraw the screen
    updateDirection()
    os.queueEvent("tick", players)
    -- queue a tick event with the players inputted
    -- somewhere else can handle the multiplayer part of this
    os.sleep(tickSpeed)
  end
end

-- returns a random position for an apple to be positioned
local function app()
  return {math.random(1, mx), math.random(1, my)}
end

-- generates apples if needed
local function genApples()
  if #apples < #players then
    apples[#apples + 1] = app()
  end
end

-- checks if a player's head is on an apple
local function checkApples()
  for i = 1, #players do
    local player = players[i]

    for j = 1, #apples do
      local apple = apples[j]

      if player.x == apple[1] and player.y == apple[2] then
        player.lengthLeft = player.lengthLeft + 2
      end
    end
  end
end

local function checkCrashes()
  -- loop through each player and check if we've crashed into them
  -- including ourself
  for i = 1, #players do
    local player = players[i]
    for j = 1, #players do
      local player2 = players[j]
      local p2Pos = calcSnakePos(player2.tailQueue, player2.tx, player2.ty)

      -- for each position, check if the player's head is on this space
      for k = 1, #p2Pos do
        if player.x == p2Pos[k][1] and player.y == p2Pos[k][2] then
          player.alive = false
          error("Player " .. tostring(i) .. " has died. (by player " .. tostring(j) .. ")", 0)
        end
      end
    end
  end
end

local function checkPlayers()
  for i = 1, #players do
    local player = players[i]
    if player.lengthLeft > 0 then
      player.lengthLeft = player.lengthLeft - 1
    end
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
      if players[player].ldir ~= (dir + 2) % 4 then
        players[player].dir = dir -- allow the turn to complete
      end
    elseif ev[1] == "tick" then
      checkApples()
      checkPlayers()
      genApples()

      checkCrashes()
    end
    debug() -- print debug stuff
  end
end

local function main()
  -- get players
  print("How many players are playing? (1 - " .. tostring(listener.maxPlayers)
        .. ")")
  local plrs = etc.getInputInt(listener.maxPlayers)

  -- create players
  for i = 1, plrs do
    players[i] = {
      x = int.mul(mx, i / (plrs + 1)),
      y = int.div(my, 2),
      dir = 0,
      ldir = 0,
      tx = int.mul(mx, i / (plrs + 1)),
      ty = int.div(my, 2) + 4,
      tdir = 0,
      tailQueue = {0, 0, 0, 0},
      alive = true,
      lengthLeft = 0
    }
  end

  -- launch game
  parallel.waitForAny(view, listener.listener, run)
end


local ok, err = pcall(main)

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
--term.clear()
--term.setCursorPos(1, 1)

if not ok then
  printError(err)
end
