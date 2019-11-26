local class = {}

class.listenerType = "Keyboard"
class.maxPlayers = 2

--[[
  update event information:
  first argument: player#
  second argument: direction
]]
function class.listener()

  local _, numPlayers = os.pullEvent("start")
  while true do
    local ev = {os.pullEvent("key")}
    -- wasd
    if ev[2] == keys.w then
      os.queueEvent("update", 1, 0)
    elseif ev[2] == keys.a then
      os.queueEvent("update", 1, 3)
    elseif ev[2] == keys.s then
      os.queueEvent("update", 1, 2)
    elseif ev[2] == keys.d then
      os.queueEvent("update", 1, 1)
    end

    -- if we have multiple players
    if numPlayers == 2 then
      -- arrow keys
      if ev[2] == keys.up then
        os.queueEvent("update", 2, 0)
      elseif ev[2] == keys.left then
        os.queueEvent("update", 2, 3)
      elseif ev[2] == keys.down then
        os.queueEvent("update", 2, 2)
      elseif ev[2] == keys.right then
        os.queueEvent("update", 2, 1)
      end
    end
  end
end

return class
