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
        is_dirty = false,
        length = length,
        bytes = table.concat(bytes),
    }

    local function replace_char(pos, str, r)
        return str:sub(1, pos - 1) .. r .. str:sub(pos + 1)
    end

    local function bytes()
        return self.bytes
    end

    local function byteLength()
        return self.length
    end    

    local function setByte(pos, val)
        assert(pos < self.length + 1, "out of range")

        self.bytes = replace_char(pos, self.bytes, val)
    end

    local function getByte(pos)
        return string.sub(self.bytes, pos, pos)
    end

    local function slice(pos, len)
        local bytes = string.sub(self.bytes, pos, pos + len)

        t = {}

        for i = 1, string.len(bytes) do
            t[i]= string.byte(string.sub(bytes, i, i))
        end

        return t
   end

    local function toHex()
        local s = string.char()

        for i = 1, self.length do
            s = s .. string.sub(self.bytes, i, i)
        end

        -- not sure why, but self.bytes doesn't seem to work 
        -- properly here, even though it should be a string 
        -- of chars
        return hex_dump(s)
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