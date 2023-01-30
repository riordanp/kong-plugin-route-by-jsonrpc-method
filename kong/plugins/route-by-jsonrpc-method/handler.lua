local stringy = require "stringy"
local cjson = require "cjson"
local cjson_safe = require "cjson.safe"
local url = require "net.url"


local plugin = {
  PRIORITY = 700,
  VERSION = "0.1",
}

local function get_content_type()
    local header_value = ngx.req.get_headers()["content-type"]
    if header_value then
        return stringy.strip(header_value):lower()
    end
    return nil
end

local function list_includes(table, value)
  for i = 1, #table do
      if table[i] == value then return true end
  end
  return false
end

local function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end


function plugin:access(plugin_conf)
  if (get_content_type() and stringy.startswith(get_content_type(), "application/json")) then
    ngx.req.read_body()
    local body = ngx.req.get_body_data()

    if not body then
      return kong.response.exit(200)
    end

    local valid = cjson_safe.decode(body)
    if not valid then
      return kong.response.error(403)
    end

    local json = cjson.decode(body)

    if json["method"] == nil then
      return kong.response.error(403)
    end

    if list_includes(plugin_conf.methods, json["method"]) then
      kong.log.debug("changing upstream to " .. plugin_conf.target_upstream_uri)

      local u = url.parse(plugin_conf.target_upstream_uri)
      kong.log.debug(dump(ngx.ctx))
      ngx.ctx.balancer_data.host = u.host
      ngx.ctx.balancer_data.port = u.port
      kong.service.request.set_path(u.path)
    end
  end
end 

return plugin
