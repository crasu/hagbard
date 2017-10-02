dfp = require("dfplayer")

local TX_PIN = 4 -- 1
local RX_PIN = 5 -- 2

local R1_YELLOW_PIN = 0
local R1_RED_PIN = 2
local R1_BLUE_PIN = 14
local R1_BLACK_PIN = 12
local R2_BLACK_PIN = 13
local R2_GREEN_PIN = 15
local R2_YELLOW_PIN = 16
local R2_RED_PIN = 10





function init()
    --[[ tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
        print("light sleep serial unstable ...")
        wifi.sleeptype(wifi.LIGHT_SLEEP)
    end)]]--
    dfp.init(TX_PIN, RX_PIN)
    dfp.reset()

    gpio.mode(R1_YELLOW_PIN, gpio.INT, gpio.PULLUP)
    gpio.mode(R1_RED_PIN, gpio.INT, gpio.PULLUP)
    gpio.mode(R1_BLUE_PIN, gpio.INT, gpio.PULLUP)
end


init()