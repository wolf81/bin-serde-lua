local _PATH = (...):match("(.-)[^%.]+$") 
local ArrayBuffer = require(_PATH .. ".array_buffer")
local DataView = require(_PATH .. ".data_view")

-- use C function for numbers greater than 32-bit
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

    function writeVarint(val)
        local r1 = bit.arshift(val, 0x3f)
        local r2 = bit.lshift(val, 0x1)
        local n = bit.bxor(r1, r2)
        writeUVarint(n)
    end

    function writeFloat(val)
        ensureSize(self, 4)
        self.view.setFloat32(self.pos, val)
        self.pos = self.pos + 4
    end

    function writeString(val)
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

    function writeBuffer(buf)
        ensureSize(self, #buf)

        for i = 1, #buf do
            local byte = string.sub(buf, i, i)
            self.view.setByte(self.pos + i, byte)
        end

        self.pos = self.pos + #buf
    end

    function writeBits(bits)
        for i = 0, #bits - 1, 8 do
            local byte = 0
            for j = 0, 7 do
                if (i + j == #bits) then
                    break
                end
                byte = bit.bor(
                    byte, 
                    bit.lshift(bits[i + j + 1] == 1 and 1 or 0, j)
                )
            end
            writeUInt8(byte)
        end
    end

    function toBuffer()
        local s = string.char()

        for i = 0, self.pos do
            s = s .. self.view.buffer().getByte(i + 1)
        end

        return s
    end

    return {
        dataView = dataView,        

        writeUInt8 = writeUInt8,
        writeUInt16 = writeUInt16,
        writeUInt32 = writeUInt32,
        writeUInt64 = writeUInt64,
        writeUVarint = writeUVarint,
        writeVarint = writeVarint,
        writeFloat = writeFloat,
        writeString = writeString,
        writeBuffer = writeBuffer,
        writeBits = writeBits,

        toBuffer = toBuffer,
    }
end

setmetatable(Writer, {
    __call = Writer.new,
})

local Reader = {}

Reader.new = function(_, view)
    local self = {
        pos = 0,
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

    function readVarint()
        local val = readUVarint() * 1LL
        local r1 = bit.rshift(val, 0x1)
        local r2 = -(bit.band(val, 0x1))
        return bit.bxor(r1, r2)
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

    function readBuffer(num_bytes)
        local bytes = self.view.slice(self.pos, num_bytes)
        self.pos = self.pos + num_bytes
        return string.char(unpack(bytes))
    end

    function readBits(num_bits)
        local num_bytes = math.ceil(num_bits / 8)
        local bytes = self.view.slice(self.pos, num_bytes)
        local bits = {}
        for _, byte in ipairs(bytes) do
            for i = 0, 7 do
                if #bits >= num_bits then break end
                bits[#bits + 1] = bit.band(bit.rshift(byte, i), 1)
            end
        end
        
        self.pos = self.pos + num_bytes

        return bits
    end

    function remaining()
        return self.view.byteLength() - self.pos
    end

    return {
        dataView = dataView,

        readUInt8 = readUInt8,
        readUInt16 = readUInt16,
        readUInt32 = readUInt32,
        readUInt64 = readUInt64,
        readUVarint = readUVarint,
        readVarint = readVarint,
        readFloat = readFloat,
        readString = readString,
        readBuffer = readBuffer,
        readBits = readBits,

        remaining = remaining,
    }
end

setmetatable(Reader, {
    __call = Reader.new,
})

return {
    Writer = Writer,
    Reader = Reader,
}