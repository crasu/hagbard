function debounce (func)
    local last = 0
    local delay = 5000000 -- 5000ms * 1000 as tmr.now() has μs resolution

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
 --   R1_YELLOW_PIN = make_key_entry(3, 1),
    R1_RED_PIN = make_key_entry(4, 1), 
    R1_BLUE_PIN = make_key_entry(5, 2),
    R1_BLACK_PIN = make_key_entry(6, 3),
    R2_BLACK_PIN = make_key_entry(7, 4),
    R2_GREEN_PIN = make_key_entry(8, 5),  -- pin has a hardware pulldown
    R2_YELLOW_PIN = make_key_entry(12, 6),
    R2_RED_PIN = make_key_entry(11, 7) 
}

dfp = require("dfplayer")

function init()
    print("Setting up dfplayer communication")
    local DFP_TX_PIN = 4 -- 1
    local DFP_RX_PIN = 5 -- 2
    dfp.init(DFP_TX_PIN, DFP_RX_PIN)
    dfp.set_volume(20)

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

    wifi.setmode(wifi.NULLMODE)
    dfp.play_folder(2)
end

init()
