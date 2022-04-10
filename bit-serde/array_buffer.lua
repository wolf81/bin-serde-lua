local ArrayBuffer = {}

local function hex_dump(buf)
    for i=1,math.ceil(#buf/16) * 16 do
        if (i-1) % 16 == 0 then io.write(string.format('%08X  ', i-1)) end
        io.write( i > #buf and '   ' or string.format('%02X ', buf:byte(i)) )
        if i %  8 == 0 then io.write(' ') end
        if i % 16 == 0 then io.write( buf:sub(i-16+1, i):gsub('%c','.'), '\n' ) end
    end
end

ArrayBuffer.new = function(_, length)
    local bytes = {}

    -- we need to use the default Lua 1-indexing here for table.concat to work
    -- properly
    for i = 1, length do
        bytes[i] = string.char(0x00)
    end

    local self = {
        length = length,
        bytes = bytes,
    }

    local function bytes()
        -- TODO: should be of type string.char() ?
        return table.concat(self.bytes)
    end

    local function byteLength()
        return self.length
    end    

    local function setByte(pos, val)
        assert(pos < self.length + 1, "out of range")
        
        self.bytes[pos] = val
    end

    local function getByte(pos)
        return self.bytes[pos]
    end

    local function slice(pos, len)
        local bytes = {}

        for i = pos, pos + len do
            bytes[#bytes + 1] = string.byte(self.bytes[i + 1])
        end

        return bytes
   end

    local function toHex()
        return hex_dump(table.concat(self.bytes))
    end

    return setmetatable({
        bytes = bytes,
        byteLength = byteLength,
        setByte = setByte,
        getByte = getByte,
        slice = slice,
        toHex = toHex,
    }, ArrayBuffer)
end

setmetatable(ArrayBuffer, {
    __call = ArrayBuffer.new,
})

return ArrayBuffer