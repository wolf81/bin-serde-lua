local _PATH = (...):gsub('%.init$', '')

local serde = require(_PATH .. ".bin-serde")

local M = {
    _VERSION = "0.1.0",
    _DESCRIPTION = "A binary encoder & decoder for Hathora",
    _URL = "https://github.com/wolf81/bin-serde-lua",
    _LICENSE = [[
        MIT License
        Copyright (c) 2022 Wolftrail
        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:
        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.
        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]], 
}

M.Writer = serde.Writer
M.Reader = serde.Reader
M.DataView = serde.DataView
M.ArrayBuffer = serde.ArrayBuffer

return M