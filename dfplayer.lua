softuart.setup(9600, 5, 4);
softuart.on("data", 1, function(data) print("lua handler called"); print(data) end);

write=softuart.write

function sseq(seq)
    for _, s in pairs(seq) do
        print(s);
        write(0x7e);
    end
end

sseq({0x7E, 0xFF, 0x06, 0x03, 00, 00, 0x01, 0xFE, 0xF7, 0xEF})



