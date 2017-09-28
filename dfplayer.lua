local dfplayer = {}, ...

local bit = require("bit")

local VERSION = 0xFF
local LENGTH = 0x06
local FEEDBACK = 0x01

function init_defaults()
    init(5, 4, 16)
end

function init(tx_pin, rx_pin, busy_pin)
    softuart.setup(9600, tx_pin, tx_pin);
    softuart.on("data", 1, function(data) print("lua handler called"); print(data) end);
end

function print_table(table)
    local output = "{"
    for k,v in pairs(table) do
        output = output .. " " .. k .. "= " .. v .. ", "
    end
    output = output .. "}"
    print(output)
end

function dfplayer.calc_checksum(cmd, param1, param2)
    checksum = -(VERSION + LENGTH + cmd + FEEDBACK + param1 + param2)
    return bit.rshift(checksum, 8), bit.band(checksum, 0xFF)
end

function dfplayer.send_command(cmd, param1, param2)
    sum1, sum2 = calc_checksum(cmd, param1, param2)
    message={0x7E, VERSION, LENGTH, cmd, FEEDBACK, param1, param2, sum1, sum2, 0xEF}
    send_seq(message)
end

function dfplayer.send_seq(seq)
    for _, s in pairs(seq) do
        softuart.write(s);
    end
end

function dfplayer.play()
    send_command(0x03, 00, 00)
end



return dfplayer

