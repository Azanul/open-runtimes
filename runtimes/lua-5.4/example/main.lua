local http = require("lapis.nginx.http")
--    'req' variable has:
--        'headers' - object with request headers
--        'payload' - object with request body data
--        'variables' - object with function variables
--    'res' variable has:
--        'send(text, status)' - function to return text response. Status code defaults to 200
--        'json(obj, status)' - function to return JSON response. Status code defaults to 200
   
--    If an error is thrown, a response with code 500 will be returned.

local function main(req, res)
    local body, status_code, headers = http.simple({
        url = "https://jsonplaceholder.typicode.com/todos/1",
        method = "GET"
      })
    res.json({
        {
            message = 'Hello Open Runtimes 👋',
            todo = body
        }, 200
    })
end

return main