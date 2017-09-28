local dfplayer = {}, ...

local bit = require("bit")

local VERSION = 0xFF
local LENGTH = 0x06
local FEEDBACK = 0x00
local DEBUG = 1

dfplayer.EQ_NORMAL = 1
dfplayer.EQ_POP = 2
dfplayer.EQ_ROCK = 3
dfplayer.EQ_JAZZ = 4
dfplayer.EQ_CLASSIC = 5
dfplayer.EQ_BASE = 6


function dfplayer.init(tx_pin, rx_pin, busy_pin)
    softuart.setup(9600, tx_pin, rx_pin);
    softuart.on("data", 1, function(data) print("lua handler called"); print(data) end);
end

function dfplayer.init_default()
    dfplayer.init(4, 5, 16)
end

function dfplayer.print_table(table)
    local output = "{"
    for k,v in pairs(table) do
        output = output .. " " .. k .. " = " .. v .. ", "
    end
    output = output .. "}"
    print(output)
end

function dfplayer.split_number(number)
    return bit.band(bit.rshift(number, 8), 0xFF), bit.band(number, 0xFF)
end

function dfplayer.calc_checksum(cmd, param1, param2)
    checksum = -(VERSION + LENGTH + cmd + FEEDBACK + param1 + param2)
    return dfplayer.split_number(checksum)
end

function dfplayer.send_command(cmd, param1, param2)
    sum1, sum2 = dfplayer.calc_checksum(cmd, param1, param2)
    message = {0x7E, VERSION, LENGTH, cmd, FEEDBACK, param1, param2, sum1, sum2, 0xEF}
    dfplayer.send_seq(message)
end

function dfplayer.send_seq(seq)
    for _, s in pairs(seq) do
        if DEBUG then
            print(string.format("Send byte: %x", s))
        end
        softuart.write(s);
    end
end

function dfplayer.next()
    dfplayer.send_command(0x01, 0, 0)
end

function dfplayer.prev()
    dfplayer.send_command(0x02, 0, 0)
end

function dfplayer.play(track)
    low, high = dfplayer.split_number(track)
    dfplayer.send_command(0x03, low, high)
end

function dfplayer.volume_up()
    dfplayer.send_command(0x04, 0, 0)
end

function dfplayer.volume_down()
    dfplayer.send_command(0x05, 0, 0)
end

function dfplayer.volume(track)
    low, high = dfplayer.split_number(track)
    dfplayer.send_command(0x06, low, high)
end

function dfplayer.set_equalizer_mode(mode)
    if mode > 6 then
        print("Mode " .. mode .. " out of range")
        return
    end
    dfplayer.send_command(0x07, 0, mode)
end

function dfplayer.playback()
    dfplayer.send_command(0x0D, 0, 0)
end

function dfplayer.playback()
    dfplayer.send_command(0x0D, 0, 0)
end

function dfplayer.pause()
    dfplayer.send_command(0x0E, 0, 0)
end

return dfplayer

