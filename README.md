# Project Title

This is a test task for the interview.

## Content

This repository includes a server app (server.lua), which contains the most interesting stuff, and client application that was made for convenience' sake.

GET, POST, PUT and DELETE are implemented. Every action is logged in server.log.

## Usage
server.lua \<host\> \<port\> (for local use: 127.0.0.1 12345)

POST: client.lua \<url\> POST \<key\> \<data\>
  
PUT: client.lua \<url\> PUT \<id\> \<data\>
  
GET: client.lua \<url\> GET \<id\>
  
DELETE: client.lua \<url\> DELETE \<id\> (for local use: url = "http://localhost:12345/")
