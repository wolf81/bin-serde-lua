io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local serde = require "bin-serde"
local Writer = serde.Writer
local Reader = serde.Reader

function love.load(args)
    local writer = Writer()

    writer.writeUInt8(5)
    writer.writeUInt32(324)
    writer.writeUInt64(644423)
    writer.writeUVarint(12333)
    writer.writeFloat(5.3324)
    writer.writeString("apple")
    writer.writeString("pear")

    local reader = Reader(writer.dataView())

    print(reader.dataView().toHex())

    print(reader.readUInt8())
    print(reader.readUInt32())
    print(reader.readUInt64())
    print(reader.readUVarint())
    print(reader.readFloat())
    print(reader.readString())
    print(reader.readString())
end