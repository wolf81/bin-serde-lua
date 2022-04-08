local ArrayBuffer = {}

local function replace_char(pos, str, r)
    return str:sub(1, pos - 1) .. r .. str:sub(pos + 1)
end

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

    for i = 1, length do
        bytes[i] = string.char(0x00)
    end

    local self = {
        bytes = bytes,
    }

    function bytes()
        return table.concat(self.bytes)
    end

    function byteLength()
        return #self.bytes
    end    

    function setByte(pos, val)
        self.bytes[pos] = val
    end

    function getByte(pos)
        return string.byte(self.bytes[pos])
    end

    function toHex()
        return hex_dump(table.concat(self.bytes))
    end

    return {
        bytes = bytes,
        byteLength = byteLength,
        setByte = setByte,
        getByte = getByte,
        toHex = toHex,
    }
end

setmetatable(ArrayBuffer, {
    __call = ArrayBuffer.new,
})

return ArrayBuffer