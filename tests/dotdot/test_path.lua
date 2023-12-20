local Test = {}

Test.new = {
  fn = function(path) return require("path"):new(path) end,
  format = "Path(%s)",
  arguments = {
    { ".", { "" } },
    { ".", { "." } },
    { ".", { "./" } },
    { "./.", { "./." } },
    { "./.", { "././" } },
    { "/", { "/" } },
    { "/", { "//" } },
    { "/", { "///." } },
    { "/.", { "///./" } },
    { "/..", { "/../" } },
    { "./..", { "./../" } },
    { "./../.", { "./../." } },
    { "./.././..", { "./..//./../" } },
  },
}

Test.parent = {
  fn = function(path) return require("path"):new(path):parent() end,
  format = "Path(%s):parent()",
  arguments = {
    { "/", { "/" } },
    { "/", { "//" } },
    { "/", { "///" } },
    { "/", { "/./" } },
    { "/", { "/a" } },
    { "/", { "/a/" } },
    { "/a/b", { "/a/b/c.d" } },
    { "/a/b", { "/a/b/c.d/" } },
  },
}

Test.join = {
  fn = function(p1, p2) require("path"):new(p1):join(p2) end,
  format = "Path(%s):join(%s)",
  arguments = {
    { "/path/to/d/e/f.txt", { "/path/to", "d/e/f.txt" } },
    { "/d/e/f.txt", { "/path/to", "/d/e/f.txt" } },
  },
}

return Test
