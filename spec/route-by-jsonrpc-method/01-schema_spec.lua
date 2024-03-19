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
            upstreams = { { uri = "new-upstream", methods = { 'test' }, }, { uri = "new-upstream1", methods = { 'test' }, } }
        }))
    end)

    describe("Errors: ", function()
        it("should not accept invalid type for `upstreams`", function()
            local ok, err = validate({
                upstreams = "blah",
            })
            assert.falsy(ok)
            assert.same({ upstreams = "expected an array" }, err.config)
        end)
        it("should not accept if `upstreams` is missing", function()
            local ok, err = validate({
            })
            assert.falsy(ok)
            assert.same({ upstreams = "required field missing" }, err.config)
        end)

        it("should not accept invalid type for `methods`", function()
            local ok, err = validate({
                upstreams = {{ uri = "new-upstream", methods = "test" }},
            })
            assert.falsy(ok)
            assert.same({upstreams = {{ methods = "expected an array" }}}, err.config)
        end)
    end)
end)
