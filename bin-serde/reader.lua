local _PATH = (...):match("(.-)[^%.]+$") 
local DataView = require(_PATH .. ".data_view")

local Reader = {}

Reader.new = function(_, view)
    local self = {
        pos = 0,
        view = view,
    }

    local function dataView()
        return self.view
    end

    local function readUInt8()
        local v = self.view.getUInt8(self.pos)
        self.pos = self.pos + 1
        return v
    end

    local function readUInt16()
        local v = self.view.getUInt16(self.pos)
        self.pos = self.pos + 2
        return v
    end

    local function readUInt32()
        local v = self.view.getUInt32(self.pos)
        self.pos = self.pos + 4
        return v
    end

    local function readUInt64()
        local v = self.view.getUInt64(self.pos)
        self.pos = self.pos + 8
        return v
    end

    local function readUVarint()
        local val = 0

        while true do
            local byte = self.view.getUInt8(self.pos)
            self.pos = self.pos + 1

            if byte < 0x80 then return val + byte end

            val = (val + bit.band(byte, 0x7f)) * 128
        end
    end

    local function readVarint()
        local val = readUVarint() * 1LL
        local r1 = bit.rshift(val, 0x1)
        local r2 = -(bit.band(val, 0x1))
        return bit.bxor(r1, r2)
    end

    local function readFloat()
        local v = self.view.getFloat32(self.pos)
        self.pos = self.pos + 4
        return v
    end

    local function readString()
        local len = readUVarint()
        
        if len == 0 then return "" end

        local v = self.view.getString(self.pos, len)
        self.pos = self.pos + len
        return v
    end

    local function readBuffer(num_bytes)
        local bytes = self.view.slice(self.pos, num_bytes)
        self.pos = self.pos + num_bytes
        return string.char(unpack(bytes))
    end

    local function readBits(num_bits)
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

    local function remaining()
        return self.view.byteLength() - self.pos
    end

    return setmetatable({
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
    }, Reader)
end

setmetatable(Reader, {
    __call = Reader.new,
})

return Reader