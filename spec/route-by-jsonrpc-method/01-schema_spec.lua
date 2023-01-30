local PLUGIN_NAME = "route-by-jsonrpc-method"


local validate
do
    local validate_entity = require("spec.helpers").validate_plugin_config_schema
    local plugin_schema = require("kong.plugins." .. PLUGIN_NAME .. ".schema")

    function validate(data)
        return validate_entity(data, plugin_schema)
    end
end


describe(PLUGIN_NAME .. ": (schema)", function()

    it("should accept a valid configuration", function()
        assert(validate({
            target_upstream_uri = "new-upstream",
            methods = { 'test' },
        }))
    end)

    describe("Errors: ", function()
        it("should not accept invalid type for `target_upstream`", function()
            local ok, err = validate({
                target_upstream_uri = {},
                methods = {},
            })
            assert.falsy(ok)
            assert.same({ target_upstream_uri = "expected a string" }, err.config)
        end)
        it("should not accept if `target_upstream` is missing", function()
            local ok, err = validate({
                methods = {},
            })
            assert.falsy(ok)
            assert.same({ target_upstream_uri = "required field missing" }, err.config)
        end)

        it("should not accept invalid type for `methods`", function()
            local ok, err = validate({
                target_upstream_uri = "new-upstream",
                methods = "test",
            })
            assert.falsy(ok)
            assert.same({ methods = "expected an array" }, err.config)
        end)
        it("should not accept if `methods` is missing", function()
            local ok, err = validate({
                target_upstream_uri = "new-upstream",
            })
            assert.falsy(ok)
            assert.same({ methods = "required field missing" }, err.config)
        end)

    end)

end)
