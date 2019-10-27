#!/usr/bin/env tarantool
assert(arg[1], 'Command is required')
local http_client = require('http.client')
local json = require('json')

local function post()
	assert(arg[2], 'Key is required')
	assert(arg[3], 'Value is required')
	local r = http_client.post('http://localhost:12345/kv', json.encode({key = arg[2], value = arg[3]}))
	print(r.status)
end

local function put()
	assert(arg[2], 'id is required')
	assert(arg[3], 'Value is required')
	local r = http_client.put('http://localhost:12345/kv/'..tostring(arg[2]), json.encode({value = arg[3]}))
	print(r.status)
end

local function get()
	assert(arg[2], 'id is required')
	local r = http_client.get('http://localhost:12345/kv/'..tostring(arg[2]))
	print(r.status)
	if(r.status == 200) then 
		print(r.body)
	end
end

local function delete()
	assert(arg[2], 'id is required')
	local r = http_client.delete('http://localhost:12345/kv/'..tostring(arg[2]))
	print(r.status)
end


if(arg[1] == 'GET') then
	get()
end

if(arg[1] == 'POST') then
	post()
end

if(arg[1] == 'PUT') then
	put()
end

if(arg[1] == 'DELETE') then
	delete()
end
