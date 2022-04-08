io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local serde = require "bit-serde"
local Writer = serde.Writer
local Reader = serde.Reader

function love.load(args)
    local writer = Writer()

    -- writer.writeUInt8(5)
    -- writer.writeUInt32(324)
    -- writer.writeUInt64(644423)
    -- writer.writeUVarint(12)
    -- writer.writeUVarint(123334)
    -- writer.writeFloat(5.3324)
    -- writer.writeString("apple")
    -- writer.writeString("pear")
    writer.writeUVarint(77577847222LL)

    local reader = Reader(writer.dataView())

    print(reader.dataView().toHex())

    -- print(reader.readUInt8())
    -- print(reader.readUInt32())
    -- print(reader.readUInt64())
    -- print(reader.readUVarint())
    -- print(reader.readUVarint())
    -- print(reader.readFloat())
    -- print(reader.readString())
    -- print(reader.readString())
    print(reader.readUVarint())
end