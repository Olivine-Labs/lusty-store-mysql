local query = require 'lusty-store-mysql.query'
local connection = require 'lusty-store-mysql.store.mysql.connection'

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
    q = "DELETE FROM "..config.collection..(#q>0 and " WHERE "..q or "")..";"
    local results = {}
    local res, err, errno, sqlstate = db:query(q)
    if not res then
      return nil, "Query |"..q.."| failed: "..err
    end
    return res
  end
}
