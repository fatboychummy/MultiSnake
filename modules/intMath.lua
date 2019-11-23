local funcs = {}

-- a shitty thing which just math.floor's everything
-- looks cool
-- wacky
-- such math, much wow

function funcs.add(x, y)
  return math.floor(x + y)
end

function funcs.sub(x, y)
  return funcs.add(x, -y)
end

function funcs.mul(x, y)
  return math.floor(x * y)
end

function funcs.div(x, y)
  return math.floor(x / y)
end

function funcs.mod(x, y)
  return math.floor(x % y)
end

function funcs.pow(x, y)
  return math.floor(math.floor(x ^ y))
end

return funcs
