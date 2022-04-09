io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local serde = require "bit-serde"
local Writer = serde.Writer
local Reader = serde.Reader

local function printBits(bits)
    local s = ""
    for i, b in ipairs(bits) do
        s = s .. b
        if i % 8 == 0 then
            s = s .. " "
        end 
    end
    print(s)
end

function love.load(args)
    local writer = Writer()

    writer.writeBits({ 0, 0 })
    writer.writeBits({ 1, 1, 0, 0, 0, 0, 1, 1 })
    writer.writeBits({ 0, 1, 1, 0 })

    writer.writeUInt8(5)
    writer.writeUInt32(324)
    writer.writeUInt64(644423)
    writer.writeUVarint(12)
    writer.writeUVarint(123334)
    writer.writeFloat(5.3324)

    -- copy buffer at this position, so we can write this data to a new writer
    local buffer = writer.toBuffer()

    writer.writeString("apple")
    writer.writeString("pear")
    writer.writeUVarint(7757784722ULL) -- 5 bytes
    writer.writeString("a")
    writer.writeUVarint(3757784722241ULL) -- 6 bytes
    writer.writeVarint(-1322223422322LL) 

    local data = string.char(0x00, 0xDE, 0xAD, 0xBE, 0xEF)
    writer.writeBuffer(data)
    writer.writeBuffer(data)

    -- grow buffer to 128 bytes
    writer.writeBuffer(data)

    -- TODO: reader & writer should be able to use same data view object

    local reader = Reader(writer.dataView())

    print(reader.dataView().toHex())

    printBits(reader.readBits(2))
    printBits(reader.readBits(8))
    printBits(reader.readBits(4))

    print(reader.readUInt8())
    print(reader.readUInt32())
    print(reader.readUInt64())
    print(reader.readUVarint())
    print(reader.readUVarint())
    print(reader.readFloat())
    print(reader.readString())
    print(reader.readString())
    print(reader.readUVarint())
    print(reader.readString())    
    print(reader.readUVarint())
    print(reader.readVarint())
    print(reader.readBuffer(#data))

    -- here we copy the previously copied buffer to new writer and log result
    local writer2 = Writer()
    writer2.writeBuffer(buffer)
    print(writer2.dataView().toHex())

    print("remaining " .. reader.remaining() .. " bytes")
end