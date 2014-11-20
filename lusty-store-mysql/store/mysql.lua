local util = require 'lusty.util'
local methods = {}
local packageName = (...):match("(.-)[^%.]+$")
return {
  handler = function(context)
    local methodName = string.lower(context.method)
    local method = methods[methodName]
    if not method then
      method = util.inline(packageName..'mysql.'..methodName, {channel = channel, config = config}).handler
      methods[methodName] = method
    end
    return method(context)
  end
}
