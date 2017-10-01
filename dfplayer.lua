-- needs


local dfplayer = {}, ...

local bit = require("bit")

local VERSION = 0xFF
local LENGTH = 0x06
local FEEDBACK = 0x00
local DEBUG = 1

dfplayer.EQ_NORMAL = 0
dfplayer.EQ_POP = 1
dfplayer.EQ_ROCK = 2
dfplayer.EQ_JAZZ = 3
dfplayer.EQ_CLASSIC = 5
dfplayer.EQ_BASE = 5

dfplayer.PBM_REPEAT = 0
dfplayer.PBM_FOLDER_REPEAT = 1
dfplayer.PBM_SINGLE_REPEAT = 2
dfplayer.PBM_RANDOM = 3

dfplayer.SOURCE_U_DISK = 1
dfplayer.SOURCE_SD = 2
dfplayer.SOURCE_AUX = 3
dfplayer.SOURCE_SLEEP = 4
dfplayer.SOURCE_FLASH = 5

dfplayer.ERROR_BUSY = 1
dfplayer.ERROR_SLEEPING = 2
dfplayer.ERROR_SERIALWRONGSTACK = 3
dfplayer.ERROR_CHECKSUMNOTMATCH = 4
dfplayer.ERROR_FILEINDEXOUT = 5
dfplayer.ERROR_FILEMISMATCH = 6
dfplayer.ERROR_ADVERTISE = 7

function dfplayer.serial_hander(data)
    local len = string.len(data)
    if DEBUG then
        print("Message from player\nlength:");
        print(len)
    end
    local bytes = {string.byte(data,0,10)}

    if(len == 10) then
        local cmd = bytes[4]
        local param1 = bytes[6]
        local param2 = bytes[7]

        local msg_chk1 = bytes[8]
        local msg_chk2 = bytes[9]

        local chk1, chk2 = dfplayer.calc_checksum(cmd, param1, param2)
        if chk1 == msg_chk1 and chk2 == msg_chk2 then
            if DEBUG  then
                print("checksum ok:")
                print(string.format("Command %x Param1 %x Param2 %x", cmd, param1, param2))
            end
        else
            print("checksum error:")
            print(string.format(string.rep ("%x ", len), unpack(bytes)))
        end

    else
        print(string.format("Invalid Message length %d != 10\n Message:", len))
        print(string.format(string.rep ("%x ", len), unpack(bytes)))
    end
end

function dfplayer.init(tx_pin, rx_pin, busy_pin)
    softuart.setup(9600, tx_pin, rx_pin);
    softuart.on("data", string.char(0xef), dfplayer.serial_hander);
end

function dfplayer.init_default()
    dfplayer.init(4, 5, 16)
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

function dfplayer.set_volume(volume)
    dfplayer.send_command(0x06, 0, volume)
end

function dfplayer.set_equalizer_mode(mode)
    if mode > 5 or mode < 0 then
        print("Mode " .. mode .. " out of range")
        return
    end
    dfplayer.send_command(0x07, 0, mode)
end

function dfplayer.set_playback_source(mode)
    if mode > 4 or mode < 1 then
        print("Mode " .. mode .. " out of range")
        return
    end
    dfplayer.send_command(0x09, 0, mode)
end

function dfplayer.set_volume_gain(gain)
    if gain > 0x1f or gain < 0 then
        print("Gain " .. gain .. " out of range")
        return
    end
    dfplayer.send_command(0x10, 0, gain)
end

function dfplayer.open_volume_adjust(adjust)
    if adjust > 0x1f or adjust < 0 then
        print("Gain " .. adjust .. " out of range")
        return
    end
    dfplayer.send_command(0x10, 1, adjust)
end

function dfplayer.sleep()
    dfplayer.send_command(0x0A, 0, 0)
end

function dfplayer.wakeup()
    dfplayer.send_command(0x0B, 0, 0)
end

function dfplayer.reset()
    dfplayer.send_command(0x0C, 0, 0)
end

function dfplayer.resume()
    dfplayer.send_command(0x0D, 0, 0)
end

function dfplayer.pause()
    dfplayer.send_command(0x0E, 0, 0)
end

function dfplayer.play_file(folder, file)
    if folder > 10 or folder < 0 or file < 0 or file > 255 then
        print("Folder " .. folder .. " or file " .. file .. " out of range")
        return
    end
    dfplayer.send_command(0x0F, folder, file)
end

function dfplayer.enable_loop()
    dfplayer.send_command(0x11, 0, 1)
end

function dfplayer.disable_loop()
    dfplayer.send_command(0x11, 0, 0)
end

function dfplayer.query_track()
    dfplayer.send_command(0x48, 0, 0)
end

function dfplayer.query_current_track()
    dfplayer.send_command(0x4C, 0, 0)
end

function dfplayer.play_folder(folder)
    if folder > 10 or folder < 0 then
        print("Folder " .. folder .. " out of range")
        return
    end
    dfplayer.send_command(0x17, 0, folder)
end

return dfplayer

