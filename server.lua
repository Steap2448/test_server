#!/usr/bin/env tarantool
local http_router = require('http.router')
local http_server = require('http.server')
local json = require('json')
local log = require('log')

function get_id_from_path(path)
    local i = -1
    local res = ""
    while (path:sub(i, i) ~= '/') do
        res = path:sub(i, i)..res
        i = i - 1
    end
    return res
end

assert(arg[1], "Require host")
assert(arg[2], "Require port")

box.cfg{
    log = 'server.log',
    pid_file = 'server.pid',
    log_level = 5,
    background = true
}

if not box.space.mainfold then
    box.schema.create_space('mainfold', {
        format = {
            {name = 'id';       type = 'string'},
            {name = 'data';     type = '*'},
        };
        if_not_exists = true;
    })

    box.space.mainfold:create_index('primary', {
        parts = {1, 'string'};
        if_not_exists = true;
    })
end

mainfold = box.space.mainfold

local httpd = http_server.new(arg[1], tonumber(arg[2]), {
    log_requests = true,
    log_errors = true
})

local function get(req)
    local id = get_id_from_path(req:path())
    local data = mainfold:get(id)

    if (data == nil) then 
        local message = "GET: id \'%s\' doesn't exist"
        log.warn(message:format(id))
        
        return {status = 404, body = json.encode("id doesn't exist")}
    end

    local message = "GET: tuple with id \'%s\' has been sent"
    log.info(message:format(id))
    
    return {status = 200, body = json.encode(data)}
end

local function post(req)
    local body = {}
    if not pcall(function() body = json.decode(req:read()) end) then
        local message = "POST: Invalid body."
        log.warn(message)
        
        return {status = 400, body = "Invalid body"}
    end

    local key = body['key']
    local value = body['value']

    if (key == nil) or (value == nil) or (type(key) ~= 'string') then
        local message = "POST: Invalid body. Key: \'%s\'"
        log.warn(message:format(key))
        
        return {status = 400, body = "Invalid body"}
    end

    local data = mainfold:get(key)
    if(data ~= nil) then
        local message = "POST: Key \'%s\' exists"
        log.warn(message:format(key))
        
        return {status = 409, body = "Key exists"}
    end

    data = {key, value}
    mainfold:insert{key, value}
    
    local message = "POST: tuple with key \'%s\' has been posted"
    log.info(message:format(key))

    return {status = 200, body = json.encode(data)}

end

local function put(req)
    local body = {}
    if not pcall(function() body = json.decode(req:read()) end) then
        local message = "PUT: Invalid body"
        log.warn(message)
        
        return {status = 400, body = "Invalid body"}
    end

    local id = get_id_from_path(req:path())
    local value = body['value']

    if (value == nil) then
        local message = "PUT: Invalid body. id: \'%s\'"
        log.warn(message:format(id))
        
        return {status = 400, body = "Invalid body"}
    end

    local data = mainfold:get(id)
    if(data == nil) then
        local message = "PUT: id \'%s\'  doesn't exist"
        log.warn(message:format(id))
        
        return {status = 404, body = "id doesn't exist"}
    end

    data = {id, value}
    mainfold:replace{id, value}
    
    local message = "PUT: tuple with id \'%s\' has been updated"
    log.info(message:format(id))
    
    return {status = 200, body = json.encode(data)}

end

local function delete(req)
    local id = get_id_from_path(req:path())
    local data = mainfold:delete(id)
    
    if (data == nil) then
        local message = "DELETE: id \'%s\'  doesn't exist"
        log.warn(message:format(id)) 
        
        return {status = 404, body = "id doesn't exist"}
    end
    
    local message = "DELETE: tuple with id \'%s\' has been deleted"
    log.info(message:format(id))

    return {status = 200, body = json.encode("Success")}
end

local router = http_router.new()
    :route({
            method = 'GET',
            path = '/kv/.*',
        },
        get
    )
    :route({
            method = 'DELETE',
            path = '/kv/.*',
        },
        delete
    )
    :route({
            method = 'POST',
            path = '/kv',
        },
        post
    )
    :route({
            method = 'PUT',
            path = '/kv/.*',
        },
        put
    )


httpd:set_router(router)
httpd:start()