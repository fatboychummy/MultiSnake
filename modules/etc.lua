local funcs = {}

-- returns an integer read from stdin
local function inputInt()
  local out = ""
  while type(out) == "string" do
    out = tonumber(io.read())
    if type(out) ~= "number" or out % 1 ~= 0 then
      out = ""
    end
  end
  return out
end

-- returns the following:
-- if no inputs:
  -- any integer
-- if range defined:
  -- an integer between 1 and range
-- if range and range2 defined:
  -- an integer between range and range2

-- range and range2 are inclusive.
function funcs.getInputInt(range, range2)
  if range then
    if range2 then
      -- min and max defined
      local x = inputInt()
      while x < range or x > range2 do
        x = inputInt()
      end
      return x
    else
      -- max defined (assume 1 min)
      local x = inputInt()
      while x < 1 or x > range do
        x = inputInt()
      end
      return x
    end
  else
    -- no min or max
    return inputInt()
  end
end

function funcs.moveCursor(dir)
  local x, y = term.getCursorPos()
  x, y = funcs.sim(x, y, dir)

  term.setCursorPos(x, y)
end

function funcs.sim(x, y, dir)
  if dir == 0 then -- go up 1
    y = y - 1
  elseif dir == 2 then -- go down 1
    y = y + 1
  elseif dir == 1 then -- go right 1
    x = x + 1
  elseif dir == 3 then -- go left 1
    x = x - 1
  end

  return x, y
end

return funcs
