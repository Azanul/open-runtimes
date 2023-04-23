local lapis = require("lapis")
local json_params = require("lapis.application").json_params
local app = lapis.Application()

--- API call handler
app:get("/", json_params(function(self)
  if (self.req.headers['x-internal-challenge'] ~= os.getenv('INTERNAL_RUNTIME_KEY'))
  then
    return { status=401, layout = false, "Unauthorized!" }
  end

  local userFuncPath = os.getenv('INTERNAL_RUNTIME_ENTRYPOINT')
  local userFunc = require(userFuncPath).main

  local req = Request(self.params.variables, self.params.payload, self.req.headers)
  Response = self.res.new()
  local res = Response.new(self.res)

  userFunc(req, res)

  return res.response
end))

-- Request class
Request = {variables="", payload="", headers=""}

-- Response class
function Response:new(response_object)
    setmetatable(response_object, self)
    self.__index = self
    return response_object
end

function Response:send(string, status_code)
    print("The area of the square is",self.area)
end

function Response:json(object, status_code)
    print("The area of the square is",self.area)
end

return app
