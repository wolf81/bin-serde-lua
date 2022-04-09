# bit-serde-lua

Lua port of [bin-serde-ts](https://github.com/hathora/bin-serde-ts)

# Usage

In order to use this library first add this library somewhere in your project 
and import the library as such:

```lua
local serde = require "bit-serde"
```

Then, whenever you want to encode some data in the binary format, create a 
writer instance and write using appropriate data types, as such:

```lua
local writer = serde.Writer()

writer.writeBits({ 0, 1, 0, 1 }) -- array of binary data
writer.writeUInt8(5) -- 8-bit unsigned int
writer.writeUInt32(324) -- 32-bit unsigned int
writer.writeUInt64(644423) -- 64-bit unsigned int
writer.writeUVarint(12) -- unsigned int of variable size
writer.writeFloat(5.3324) -- 32-bit float
writer.writeString("apple") -- string
writer.writeUVarint(7757784722LL) -- add LL annotation for large unsigned integers (5+ bytes)

-- numbers larger than 6 bytes are not supported and will raise an error
```

In order to read, create an instance of the reader and use it as such:

```lua
local reader = serde.Reader()

reader.readBits(4) -- { 0, 1, 0, 1 }
reader.readUInt8() -- 5
reader.readUInt32() -- 324
reader.readUInt64() -- 644423
reader.readUVarint() -- 12
reader.readFloat() -- 5.3323998451233
reader.readString() -- apple
reader.readUVarint() -- 7757784722
```

Be aware that in order to decode properly, values need to be read in the same 
order as they were written.
