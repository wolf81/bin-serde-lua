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

    -- writer.writeBits({ 0, 1 })
    -- writer.writeBits({ 0, 1, 0, 0, 1, 1, 0, 0 })
    -- writer.writeBits({ 0, 1, 0, 1 })

    -- writer.writeUInt8(5)
    -- writer.writeUInt32(324)
    -- writer.writeUInt64(644423)
    -- writer.writeUVarint(12)
    -- writer.writeUVarint(123334)
    -- writer.writeFloat(5.3324)
    -- writer.writeString("apple")
    -- writer.writeString("pear")
    -- writer.writeUVarint(7757784722ULL) -- 5 bytes
    -- writer.writeString("a")
    -- writer.writeUVarint(3757784722241LL) -- 6 bytes
    writer.writeVarint(-332222)

    local reader = Reader(writer.dataView())

    print(reader.dataView().toHex())

    -- local bits = printBits(reader.readBits(2))
    -- local bits = printBits(reader.readBits(8))
    -- local bits = printBits(reader.readBits(4))

    -- print(reader.readUInt8())
    -- print(reader.readUInt32())
    -- print(reader.readUInt64())
    -- print(reader.readUVarint())
    -- print(reader.readUVarint())
    -- print(reader.readFloat())
    -- print(reader.readString())
    -- print(reader.readString())
    -- print(reader.readUVarint())
    -- print(reader.readString())    
    -- print(reader.readUVarint())
    print(reader.readVarint())

    print("remaining " .. reader.remaining() .. " bytes")
end