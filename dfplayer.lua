local dfplayer = {}, ...

local bit = require("bit")

local VERSION = 0xFF
local LENGTH = 0x06
local FEEDBACK = 0x01


function dfplayer.init(tx_pin, rx_pin, busy_pin)
    softuart.setup(9600, tx_pin, tx_pin);
    softuart.on("data", 1, function(data) print("lua handler called"); print(data) end);
end

function dfplayer.init_default()
    dfplayer.init(5, 4, 16)
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
        print(string.format("%x", s))
        softuart.write(s);
    end
end

function dfplayer.next()
    dfplayer.send_command(0x01, 00, 00)
end

function dfplayer.prev()
    dfplayer.send_command(0x02, 00, 00)
end

function dfplayer.play(track)
    low, high = dfplayer.split_number(track)
    dfplayer.send_command(0x03, low, high)
end

return dfplayer

