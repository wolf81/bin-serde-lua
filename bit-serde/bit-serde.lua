local utf8 = require "utf8"

local _PATH = (...):match("(.-)[^%.]+$") 

local ArrayBuffer = require(_PATH .. ".array_buffer")
local DataView = require(_PATH .. ".data_view")

local ffi = require("ffi")
ffi.cdef[[
double floor(double x);
]]

local function ensureSize(self, size)
    while self.view.byteLength() < self.pos + size do
        self.view = DataView(ArrayBuffer(self.view.byteLength() * 2))
    end
end

local Writer = {}

Writer.new = function()
    print("new writer")

    local buffer = ArrayBuffer(64)

    local self = {
        pos = 0,
        view = DataView(buffer),
    }

    function dataView()
        return self.view
    end

    function writeUInt8(val)
        ensureSize(self, 1)
        self.view.setUInt8(self.pos, val)
        self.pos = self.pos + 1
    end

    function writeUInt16(val)
        ensureSize(self, 2)
        self.view.setUInt8(self.pos, val)
        self.pos = self.pos + 2
    end

    function writeUInt32(val)
        ensureSize(self, 4)
        self.view.setUInt32(self.pos, val)
        self.pos = self.pos + 4
    end

    function writeUInt64(val)
        ensureSize(self, 8)
        self.view.setUInt64(self.pos, val)
        self.pos = self.pos + 8
    end

    function writeUVarint(val)
        local bit_val = bit.tobit(val)
        print("v", val)
        if val < 0x80 then
            ensureSize(self, 1)
            self.view.setUInt8(self.pos, val)
            self.pos = self.pos + 1
        elseif val < 0x4000 then
            ensureSize(self, 2)
            self.view.setUInt16(
                self.pos, 
                bit.bor(
                    bit.band(bit_val, 0x7f), 
                    bit.lshift(bit.band(bit_val, 0x3f80), 1), 
                    0x8000
                )
            )
            self.pos = self.pos + 2
        elseif val < 0x20000 then
            ensureSize(self, 3)
            self.view.setUInt8(
                self.pos, 
                bit.bor(bit.rshift(bit_val, 14), 0x80)
            )
            self.view.setUInt16(
                self.pos + 1, 
                bit.bor(
                    bit.band(bit_val, 0x7f), 
                    bit.lshift(bit.band(bit_val, 0x3f80), 1), 
                    0x8000
                )
            )
            self.pos = self.pos + 3
        elseif val < 0x10000000 then
            ensureSize(self, 4)
            self.view.setUInt32(
                self.pos,
                bit.bor(
                    bit.band(bit_val, 0x7f), 
                    bit.lshift(bit.band(bit_val, 0x3f80), 1), 
                    bit.lshift(bit.band(bit_val, 0x1fc000), 2),
                    bit.lshift(bit.band(bit_val, 0xfe00000), 3),
                    0x80808000
                )
            )
            self.pos = self.pos + 4
        elseif val < 0x800000000 then
            ensureSize(self, 5)
            self.view.setUInt8(
                self.pos, 
                bit.bor(ffi.C.floor(val / math.pow(2, 28)), 0x80)
            )
            self.view.setUInt32(
                self.pos + 1,
                bit.bor(
                    bit.band(bit_val, 0x7f), 
                    bit.lshift(bit.band(bit_val, 0x3f80), 1), 
                    bit.lshift(bit.band(bit_val, 0x1fc000), 2),
                    bit.lshift(bit.band(bit_val, 0xfe00000), 3),
                    0x80808000
                )
            )
            self.pos = self.pos + 5
        elseif val < 0x40000000000 then
            print("6 BYTES")
            ensureSize(self, 6)
            local shifted_val = ffi.C.floor(val / math.pow(2, 28))
            self.view.setUInt16(
                self.pos, 
                bit.bor(
                    bit.band(shifted_val, 0x7f), 
                    bit.lshift(bit.band(shifted_val, 0x3f80), 1), 
                    0x8080
                )
            )
            self.view.setUInt32(
                self.pos + 2,
                bit.bor(
                    bit.band(val, 0x7f), 
                    bit.lshift(bit.band(val, 0x3f80), 1), 
                    bit.lshift(bit.band(val, 0x1fc000), 2),
                    bit.lshift(bit.band(val, 0xfe00000), 3),
                    0x80808000
                )
            )
            self.pos = self.pos + 6
        else
            error("value out of range")
        end
    end

    function writeFloat(val)
        ensureSize(self, 4)
        self.view.setFloat32(self.pos, val)
        self.pos = self.pos + 4
    end

    function writeString(val)
        print("utf8 size", utf8.len(val))
        print("size", #val)
        if #val > 0 then
            local byteSize = #val
            writeUVarint(byteSize)
            ensureSize(self, byteSize)
            self.view.setString(self.pos, val)
            self.pos = self.pos + byteSize            
        else
            self.view.setUInt8(0)
        end
    end

    function writeBits()
        error("not implemented")
    end

    return {
        dataView = dataView,        

        writeUInt8 = writeUInt8,
        writeUInt16 = writeUInt16,
        writeUInt32 = writeUInt32,
        writeUInt64 = writeUInt64,
        writeUVarint = writeUVarint,
        writeFloat = writeFloat,
        writeString = writeString,
        writeBits = writeBits,
    }
end

setmetatable(Writer, {
    __call = Writer.new,
})

local Reader = {}

Reader.new = function(_, view)
    print("new reader")

    local self = {
        pos = 1,
        view = view,
    }

    function dataView()
        return self.view
    end

    function readUInt8()
        local v = self.view.getUInt8(self.pos)
        self.pos = self.pos + 1
        return v
    end

    function readUInt16()
        local v = self.view.getUInt16(self.pos)
        self.pos = self.pos + 2
        return v
    end

    function readUInt32()
        local v = self.view.getUInt32(self.pos)
        self.pos = self.pos + 4
        return v
    end

    function readUInt64()
        local v = self.view.getUInt64(self.pos)
        self.pos = self.pos + 8
        return v
    end

    function readUVarint()
        local val = 0

        while true do
            local byte = self.view.getUInt8(self.pos)
            self.pos = self.pos + 1

            if byte < 0x80 then
                return val + byte
            end

            val = (val + bit.band(byte, 0x7f)) * 128
        end
    end

    function readFloat()
        local v = self.view.getFloat32(self.pos)
        self.pos = self.pos + 4
        return v
    end

    function readString()
        local len = readUVarint()
        
        if len == 0 then return "" end

        local v = self.view.getString(self.pos, len)
        self.pos = self.pos + len
        return v
    end

    function readBits()
        error("not implemented")
    end

    return {
        dataView = dataView,

        readUInt8 = readUInt8,
        readUInt16 = readUInt16,
        readUInt32 = readUInt32,
        readUInt64 = readUInt64,
        readUVarint = readUVarint,
        readFloat = readFloat,
        readString = readString,
        readBits = readBits,
    }
end

setmetatable(Reader, {
    __call = Reader.new,
})

return {
    Writer = Writer,
    Reader = Reader,
}