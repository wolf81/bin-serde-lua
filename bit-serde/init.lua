local PATH = (...):gsub('%.init$', '')

return require(PATH..".bit-serde")
