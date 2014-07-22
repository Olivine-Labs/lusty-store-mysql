local queries = {}

local ops = {
  eq      = function(clause) return queries.simpleOp(" = ", clause) end,
  neq     = function(clause) return queries.simpleOp(" != ", clause) end,
  lt      = function(clause) return queries.simpleOp(" < ", clause) end,
  lte     = function(clause) return queries.simpleOp(" <= ", clause) end,
  gt      = function(clause) return queries.simpleOp(" > ", clause) end,
  gte     = function(clause) return queries.simpleOp(" >= ", clause) end,
  ["and"] = function(clause) return queries.subquery(" and ", clause) end,
  ["or"]  = function(clause) return queries.subquery(" or ", clause) end,
  sort    = function(clause, meta)
    meta.sort = clause.arguments[1]
  end,
  limit   = function(clause, meta)
    meta.limit = clause.arguments[1]
  end,
  fields  = function(clause, meta)
    meta.fields = clause.arguments[1]
  end,
}

local function query(query)
  local result, meta = {}, {}
  for _, clause in pairs(query) do
    local op = ops[clause.operation]
    if op then
      local res = op(clause, meta)
      if res then
        result[#result+1] = res
      end
    else
      error("Unsupported query operation '"..clause.operation.."'")
    end
  end
  return table.concat(result), meta
end


function queries.simpleOp(op, clause)
  if type(clause.arguments[1]) == "string" then
    clause.arguments[1] = ngx.quote_sql_str(clause.arguments[1])
  end
  return clause.field..op..clause.arguments[1]
end

function queries.subquery(op, clause)
  local result = {}
  for i=1, #clause.arguments do
    result[#result+1]=query(clause.arguments[i])
  end
  return " AND ("..table.concat(result, op)..")"
end

return query
