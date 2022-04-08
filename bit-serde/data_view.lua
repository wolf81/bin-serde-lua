local _PATH = (...):match("(.-)[^%.]+$") 

local struct = require(_PATH .. ".struct")

local DataView = {}

--[[
> little endian
< big endian

"b" a signed char.
"B" an unsigned char.
"h" a signed short (2 bytes).
"H" an unsigned short (2 bytes).
"i" a signed int (4 bytes).
"I" an unsigned int (4 bytes).
"l" a signed long (8 bytes).
"L" an unsigned long (8 bytes).
"f" a float (4 bytes).
"d" a double (8 bytes).
"s" a zero-terminated string.
"cn" a sequence of exactly n chars corresponding to a single Lua string (if n <= 0 then for packing - the string length is taken, unpacking - the number value of the previous unpacked value which is not returned).
--]]

local function setBytes(buffer, offset, bytes)
    for i = 1, #bytes do
        local v = string.sub(bytes, i, i)
        buffer.setByte(offset + i - 1, v)
    end
end

function DataView.new(_, buffer)
    local self = {
        buffer = buffer or ArrayBuffer(),
    }

    function buffer()
        return self.buffer
    end

    function setUInt8(pos, val)
        local bytes = struct.pack(">B", val)
        setBytes(self.buffer, pos + 1, bytes)
    end

    function setUInt16(pos, val)
        local bytes = struct.pack(">H", val)
        setBytes(self.buffer, pos + 1, bytes)        
    end

    function setUInt32(pos, val)
        local bytes = struct.pack(">I", val)
        setBytes(self.buffer, pos + 1, bytes)
    end

    function setUInt64(pos, val)
        local bytes = struct.pack(">L", val)
        setBytes(self.buffer, pos + 1, bytes)
    end

    function setFloat32(pos, val)
        local bytes = struct.pack(">f", val)
        setBytes(self.buffer, pos + 1, bytes)
    end

    function setString(pos, val)
        local bytes = struct.pack(">c" .. #val, val)
        setBytes(self.buffer, pos + 1, bytes)
    end

    function getUInt8(pos)
        return struct.unpack(">B", self.buffer.bytes(), pos + 1)
    end

    function getUInt16(pos)
        return struct.unpack(">H", self.buffer.bytes(), pos + 1)
    end

    function getUInt32(pos)
        return struct.unpack(">I", self.buffer.bytes(), pos + 1)
    end

    function getUInt64(pos)
        return struct.unpack(">L", self.buffer.bytes(), pos + 1)
    end

    function getFloat32(pos)
        return struct.unpack(">f", self.buffer.bytes(), pos + 1)
    end

    function getString(pos, len)
        return struct.unpack(">c" .. len, self.buffer.bytes(), pos + 1)
    end

    function slice(pos, len)
        local bytes = {}

        for i = pos, pos + len - 1 do
            local byte = self.buffer.getByte(i + 1)
            bytes[#bytes + 1] = byte
        end

        return bytes
   end

    function toHex()
        return self.buffer.toHex()
    end

    return {
        buffer = buffer,
        byteLength = byteLength,

        setUInt8 = setUInt8,
        setUInt16 = setUInt16,
        setUInt32 = setUInt32,
        setUInt64 = setUInt64,
        setFloat32 = setFloat32,
        setString = setString,

        getUInt8 = getUInt8,
        getUInt16 = getUInt16,
        getUInt32 = getUInt32,
        getUInt64 = getUInt64,
        getFloat32 = getFloat32,
        getString = getString,

        slice = slice,
        toHex = toHex,
    }
end

setmetatable(DataView, {
    __call = DataView.new,
})

return DataView