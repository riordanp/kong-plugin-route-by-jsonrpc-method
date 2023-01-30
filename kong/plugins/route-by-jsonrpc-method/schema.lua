local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "route-by-jsonrpc-method"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer },
    { config = {
        type = "record",
        fields = {
          { methods = {
              type = "array",
              elements = { type = "string" },
              required = true } },
          { target_upstream_uri = {
              type = "string",
              required = true } },
        },
      },
    },
  },
}

return schema
