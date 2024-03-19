local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "route-by-jsonrpc-method"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer },
    {
      config = {
        type = "record",
        fields = {
          {
            upstreams = {
              type = "array",
              elements = {
                type = "record",
                fields = {
                  {
                    uri = {
                      type = "string",
                      required = true
                    }
                  },
                  {
                    methods = {
                      type = "array",
                      elements = { type = "string" },
                      required = true
                    }
                  }
                }
              },
              required = true
            }
          },
        },
      },
    },
  },
}

return schema
