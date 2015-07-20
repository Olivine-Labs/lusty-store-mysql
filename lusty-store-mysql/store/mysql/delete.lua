local query = require 'lusty-store-mysql.query'
local connection = require 'lusty-store-mysql.store.mysql.connection'

local function keysAndValues(tbl)
  local n, keys, values = 1, {}, {}
  for k, v in pairs(tbl) do
    keys[n] = k
    values[n] = v
    n = n + 1
  end
  return keys, values
end

local function makeUpdate(tbl)
  local n, update = 1, {}
  for k, v in pairs(tbl) do
    update[n] = k..'='..ngx.quote_sql_str(v)
  end
  return table.concat(update, ' ,')
end

return {
  handler = function(context)
    local db, err = connection(lusty, config)
    if not db then error(err) end
    local q, m
    if getmetatable(context.query) then
      q, m = query(context.query)
    else
      q = context.query
    end
    local keys, values = keysAndValues(context.data)
    local update = makeUpdate(context.data)
    q = "DELETE FROM "..config.collection.." WHERE "..q..";"
    local results = {}
    local res, err, errno, sqlstate = db:query(q)
    if not res then
      return nil, "Query |"..q.."| failed: "..err
    end
    return res
  end
}
