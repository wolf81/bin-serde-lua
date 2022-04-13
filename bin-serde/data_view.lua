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

function DataView.new(_, buffer)
    local self = {
        buffer = buffer or ArrayBuffer(),
    }

    local function setBytes(offset, bytes)
        for i = 1, #bytes do
            self.buffer.setByte(offset + i, string.sub(bytes, i, i))
        end
    end

    local function buffer()
        return self.buffer
    end

    local function byteLength()
       return self.buffer.byteLength()
    end

    local function setUInt8(pos, val)
        local bytes = struct.pack("<B", val)
        setBytes(pos, bytes)
    end

    local function setUInt16(pos, val)
        local bytes = struct.pack("<H", val)
        setBytes(pos, bytes)        
    end

    local function setUInt32(pos, val)
        local bytes = struct.pack("<I", val)
        setBytes(pos, bytes)
    end

    local function setUInt64(pos, val)
        local bytes = struct.pack("<L", val)
        setBytes(pos, bytes)
    end

    local function setFloat32(pos, val)
        local bytes = struct.pack("<f", val)
        setBytes(pos, bytes)
    end

    local function setString(pos, val)
        local bytes = struct.pack("<c" .. #val, val)
        setBytes(pos, bytes)
    end

    local function setByte(pos, val)
        self.buffer.setByte(pos + 1, val)
    end

    local function getUInt8(pos)
        return struct.unpack("<B", self.buffer.bytes(), pos + 1)
    end

    local function getUInt16(pos)
        return struct.unpack("<H", self.buffer.bytes(), pos + 1)
    end

    local function getUInt32(pos)
        return struct.unpack("<I", self.buffer.bytes(), pos + 1)
    end

    local function getUInt64(pos)
        return struct.unpack("<L", self.buffer.bytes(), pos + 1)
    end

    local function getFloat32(pos)
        return struct.unpack("<f", self.buffer.bytes(), pos + 1)
    end

    local function getString(pos, len)
        return struct.unpack("<c" .. len, self.buffer.bytes(), pos + 1)
    end

    local function getByte(pos)
        return self.buffer.getByte(pos + 1)
    end

    local function slice(pos, len)
        return self.buffer.slice(pos + 1, len)
    end

    local function toHex()
        return self.buffer.toHex()
    end

    return setmetatable({
        buffer = buffer,
        byteLength = byteLength,

        setUInt8 = setUInt8,
        setUInt16 = setUInt16,
        setUInt32 = setUInt32,
        setUInt64 = setUInt64,
        setFloat32 = setFloat32,
        setString = setString,
        setByte = setByte,

        getUInt8 = getUInt8,
        getUInt16 = getUInt16,
        getUInt32 = getUInt32,
        getUInt64 = getUInt64,
        getFloat32 = getFloat32,
        getString = getString,
        getByte = getByte,

        slice = slice,
        toHex = toHex,
    }, DataView)
end

setmetatable(DataView, {
    __call = DataView.new,
})

return DataView