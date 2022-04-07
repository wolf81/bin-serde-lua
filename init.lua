local PATH = (...):gsub('%.init$', '')

return require(PATH..".bin-serde")
