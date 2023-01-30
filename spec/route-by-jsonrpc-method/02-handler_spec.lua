local PLUGIN_NAME = "route-by-jsonrpc-method"
local helpers = require "spec.helpers"

-- create 2 servers to the routed and normal traffic
local fixtures = {
  http_mock = {
    upstream = [[
    server {
      server_name upstream.com;
      listen 16798;
      keepalive_requests     10;

      location = /a {
        echo 'rerouted';
      }
    }
    ]],
    normal = [[
    server {
      server_name normal.com;
      listen 16799;
      keepalive_requests     10;

      location = / {
        echo 'normal';
      }
    }
    ]]
  }
}

local function get(client, host, method, target)
  local opts = {
    headers = {
        ["host"] = host,
        ["content-type"] = "application/json"
    },
    body = '{"method":"' .. method .. '"}'
  }

  local res = assert(client:get("/", opts))
  local res_body = assert.res_status(200, res)
  assert.equal(target, res_body)
end

for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()
      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      -- create the main service routing to the first or second one
      local mainroute = assert(bp.routes:insert({
        service = bp.services:insert({
          name = "global",
          host = "127.0.0.1",
          port = 16799,
        }),
        hosts = { "test.com" },
      }))

      -- add the plugin to the main route
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = mainroute.id },
        config = {
          target_upstream_uri = "http://127.0.0.1:16798/a",
          methods={"test"},
        },
      }
      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      },nil, nil, fixtures))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("request ", function()
      describe("with the test method ", function()
        it("on test", function()
          get(client, "test.com", "test", "rerouted")
        end)
      end)

      describe("without the test method", function()
          it("on test", function()
            get(client, "test.com", "not-test", "normal")
          end)
      end)

    end)
  end)
end