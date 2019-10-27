#!/usr/bin/env tarantool
assert(arg[1], 'URL is required')
assert(arg[2], 'Command is required')
local http_client = require('http.client')
local json = require('json')

local function post()
	assert(arg[3], 'Key is required')
	assert(arg[4], 'Value is required')
	local r = http_client.post(arg[1]..'/kv', json.encode({key = arg[3], value = arg[4]}))
	print(r.status)
end

local function put()
	assert(arg[3], 'id is required')
	assert(arg[4], 'Value is required')
	local r = http_client.put(arg[1]..'/kv/'..tostring(arg[3]), json.encode({value = arg[4]}))
	print(r.status)
end

local function get()
	assert(arg[3], 'id is required')
	local r = http_client.get(arg[1]..'/kv/'..tostring(arg[3]))
	print(r.status)
	if(r.status == 200) then 
		print(r.body)
	end
end

local function delete()
	assert(arg[3], 'id is required')
	local r = http_client.delete(arg[1]..'/kv/'..tostring(arg[3]))
	print(r.status)
end


if(arg[2] == 'GET') then
	get()
end

if(arg[2] == 'POST') then
	post()
end

if(arg[2] == 'PUT') then
	put()
end

if(arg[2] == 'DELETE') then
	delete()
end
