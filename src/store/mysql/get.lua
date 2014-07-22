local packageName = (...):match("(.-)[^%.]+$")
local query = require 'lusty-store-mysql.query'
local connection = require(packageName..'.connection')

return {
  handler = function(context)
    local db, err = connection(lusty, config)
    if not db then error(err) end
    local q, m = query(context.query)
    q = "SELECT "..(m.fields and table.concat(m.fields, ", ") or "*").." FROM "..config.collection..(#q>0 and " WHERE "..q or "")..";"
    local results = {}
    local res, err, errno, sqlstate = db:query(q)
    if not res then
      return nil, "Query |"..q.."| failed: "..err
    end
    return res
  end
}
