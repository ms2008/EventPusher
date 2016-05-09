----------------------------------------------------------------------------
-- Issue: ULUCU Log Push System
-- Copyright (C)2016 poslua <poslua@gmail.com>
----------------------------------------------------------------------------

local server = require "resty.websocket.server"
local cjson = require "cjson"

local wb, err = server:new{
    timeout = 1000,  -- in milliseconds
    max_payload_len = 65535,
}
if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end

local i = 1

while true do
    local data, typ, err = wb:recv_frame()
    if wb.fatal then
        ngx.log(ngx.ERR, "failed to receive frame: ", err)
        return ngx.exit(444)
    end
    if not data then
        math.randomseed(ngx.now())
        math.random(); math.random(); math.random()
        local demo_msg = {
            "just for test. pls go on...",
            "msg push failed, error code : 12001 reason : connect time out",
            "inspect_plan intelligent device get failed due to",
            "master pic path get failed due to",
            "parse img_cmp json failed due to some field can not recognize",
            "counter img get failed!",
            "have no any store_id found",
        }
        local demo_type = {
            "Data Level",
            "Midware",
            "Discover",
            "Device",
            "TCP Backend",
        }
        local str_t = {
            id = ngx.localtime(),
            type = demo_type[math.random(#demo_type)],
            msg  = demo_msg[math.random(#demo_msg)],
            severity = math.random(5),
            data = {
                {name = 111, age = 222},
                {333,444,555},
            }
        }
        local bytes, err = wb:send_text(cjson.encode(str_t))
        if not bytes then
            ngx.log(ngx.ERR, "failed to send text: ", err)
            return ngx.exit(444)
        end
    elseif typ == "close" then
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        ngx.log(ngx.INFO, "client ponged")
    elseif typ == "text" then
        local bytes, err = wb:send_text(data)
        if not bytes then
            ngx.log(ngx.ERR, "failed to send text: ", err)
            return ngx.exit(444)
        end
    end
    i = i + 1
end

ngx.log(ngx.ERR, "I'm Out!")
wb:send_close()

