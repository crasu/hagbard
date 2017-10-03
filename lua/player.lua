function debounce (func)
    local last = 0
    local delay = 500000 -- 50ms * 1000 as tmr.now() has μs resolution

    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;

        last = now
        return func(...)
    end
end

function make_key_entry(pin, folder)
    local key_entry = {}
    key_entry.func = debounce(function()
        print(string.format("key received: %q playing folder: %q", pin, folder))
        dfp.play_folder(folder)
    end)
    key_entry.pin = pin

    return key_entry
end


PIN_TABLE = {
    R1_YELLOW_PIN = make_key_entry(3, 1),
    R1_RED_PIN = make_key_entry(4, 2),
    R1_BLUE_PIN = make_key_entry(5, 3),
    R1_BLACK_PIN = make_key_entry(6,4),
    R2_BLACK_PIN = make_key_entry(7, 5),
    R2_GREEN_PIN = make_key_entry(8, 6),
    R2_YELLOW_PIN = make_key_entry(12,7), -- pin has a hardware pulldown
    R2_RED_PIN = make_key_entry(11,8)
}

dfp = require("dfplayer")

function init()
    --[[ tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
        print("light sleep serial unstable ...")
        wifi.sleeptype(wifi.LIGHT_SLEEP)
    end)]]--
    print("Setting up dfplayer communication")
    local DFP_TX_PIN = 4 -- 1
    local DFP_RX_PIN = 5 -- 2
    dfp.init(DFP_TX_PIN, DFP_RX_PIN)
    dfp.reset()
    dfp.set_volume(5)

    print("Setting up gpios")
    for name, entry in pairs(PIN_TABLE) do
        tmr.delay(1000)

        if not(entry.pin == 8) then
            gpio.mode(entry.pin, gpio.INT, gpio.PULLUP)
        else
            gpio.mode(entry.pin, gpio.INT)
        end

        gpio.trig(entry.pin, "both", entry.func)
    end
end

init()
